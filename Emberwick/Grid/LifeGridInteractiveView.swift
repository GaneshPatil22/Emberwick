//
//  LifeGridInteractiveView.swift
//  Emberwick
//
//  The life grid as a plain zoomable poster: pinch to magnify (crisp — the Canvas
//  redraws at the zoomed size), drag to pan when zoomed in. One row stays one year,
//  so zooming keeps the "which year am I on" feel. Tapping a cell opens its week.
//
//  The measured base is a fixed, parent-sized Color.clear; the grid is an OVERLAY,
//  so its (possibly oversized) frame can't feed back into the measured viewport.
//
//  NOTE: gesture feel is best tuned on-device (no pinch automation here).
//

import SwiftUI

struct LifeGridInteractiveView: View {
    let snapshot: GridSnapshot
    let entries: [Entry]
    let bands: [EraBand]
    let rowCount: Int
    var zoomNamespace: Namespace.ID
    let onOpenYear: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewport: CGSize = .zero
    @State private var zoom: Double = 1
    @State private var offset: CGSize = .zero
    // Baselines captured at the end of each gesture so the next one starts cleanly.
    @State private var startZoom: Double = 1
    @State private var startOffset: CGSize = .zero
    @State private var sourcePosition: GridPosition?

    // First-run intro flight.
    @State private var introFlights: [MemoryFlight] = []
    @State private var completedFlightIDs: Set<UUID> = []
    @State private var isPlayingIntro = false
    @State private var didScheduleIntro = false
    @State private var didStartIntro = false

    private let introFlightDuration: Double = 1.5
    /// Launch delays for all cards are spread across this window (independent of count).
    private let introLaunchWindow: Double = 1.8

    var body: some View {
        let content = contentSize(viewport: viewport, zoom: zoom)

        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                LifeGridView(snapshot: snapshot, bands: bands, rowCount: rowCount)
                    .frame(width: content.width, height: content.height)
                    .overlay {
                        if let sourcePosition {
                            LifeZoomSourceOverlay(
                                position: sourcePosition,
                                gridSize: content,
                                rowCount: rowCount,
                                zoomNamespace: zoomNamespace
                            )
                        }
                    }
                    .offset(x: offset.width, y: offset.height)
            }
            .clipped()
            .overlay {
                // Explicitly framed to the viewport and clipped, so positioned tokens
                // can never grow the flexible base and shove the layout down.
                IntroFlightOverlay(
                    flights: isPlayingIntro ? introFlights : [],
                    flightDuration: introFlightDuration,
                    onComplete: flightCompleted
                )
                .frame(width: viewport.width, height: viewport.height, alignment: .topLeading)
                .clipped()
                .allowsHitTesting(false)
            }
            .contentShape(.rect)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                setViewport(newSize)
            }
            .onTapGesture { location in
                handleTap(at: location)
            }
            .highPriorityGesture(magnifyGesture)
            .simultaneousGesture(panGesture)
    }

    // MARK: - Gestures

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let anchor = CGPoint(
                    x: value.startAnchor.x * viewport.width,
                    y: value.startAnchor.y * viewport.height
                )
                let newZoom = clampZoom(startZoom * value.magnification)
                let scale = newZoom / startZoom
                let proposed = CGSize(
                    width: anchor.x - (anchor.x - startOffset.width) * scale,
                    height: anchor.y - (anchor.y - startOffset.height) * scale
                )
                zoom = newZoom
                offset = clampOffset(proposed, zoom: newZoom, viewport: viewport)
            }
            .onEnded { _ in
                startZoom = zoom
                startOffset = offset
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard zoom > 1.0001 else { return }
                let proposed = CGSize(
                    width: startOffset.width + value.translation.width,
                    height: startOffset.height + value.translation.height
                )
                offset = clampOffset(proposed, zoom: zoom, viewport: viewport)
            }
            .onEnded { _ in
                startOffset = offset
            }
    }

    // MARK: - Actions

    private func handleTap(at location: CGPoint) {
        let content = contentSize(viewport: viewport, zoom: zoom)
        let metrics = GridCanvasMetrics(
            size: content,
            columns: GridConstants.columnsPerYear,
            rows: rowCount,
            gap: GridConstants.cellSpacing
        )
        let contentPoint = CGPoint(x: location.x - offset.width, y: location.y - offset.height)
        guard let position = metrics.position(
            at: contentPoint,
            rowCount: rowCount,
            columns: GridConstants.columnsPerYear
        ) else { return }
        sourcePosition = position
        onOpenYear(position.row)
    }

    private func setViewport(_ size: CGSize) {
        viewport = size
        offset = clampOffset(offset, zoom: zoom, viewport: size)
        startOffset = offset
        scheduleIntroIfNeeded()
    }

    /// Waits for the launch layout to converge before starting — otherwise the
    /// intro's animations get applied to the still-settling header/grid, sliding the
    /// whole content up on screen (the layout settling should be instant, not animated).
    private func scheduleIntroIfNeeded() {
        guard !didScheduleIntro, !reduceMotion, viewport.width > 1, viewport.height > 1 else { return }
        didScheduleIntro = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.4))
            startIntroIfNeeded()
        }
    }

    // MARK: - Intro flight

    private func startIntroIfNeeded() {
        guard !didStartIntro, !reduceMotion, viewport.width > 1, viewport.height > 1 else { return }
        let birthYear = GridMath.year(for: AppConfig.defaultBirthDate)
        let plans = IntroFlightPlanner.plans(
            entries: entries,
            snapshot: snapshot,
            birthYear: birthYear,
            launchWindow: introLaunchWindow
        )
        guard !plans.isEmpty else { return }
        didStartIntro = true

        let content = contentSize(viewport: viewport, zoom: 1)
        let metrics = GridCanvasMetrics(
            size: content,
            columns: GridConstants.columnsPerYear,
            rows: rowCount,
            gap: GridConstants.cellSpacing
        )
        let baseOffset = clampOffset(.zero, zoom: 1, viewport: viewport)
        // Emerge from the bottom edge (within bounds — positioning below would grow
        // the flexible base and shift the layout).
        let start = CGPoint(x: viewport.width / 2, y: viewport.height)

        introFlights = plans.map { plan in
            let rect = metrics.rect(row: plan.position.row, column: plan.position.column)
            let end = CGPoint(x: baseOffset.width + rect.midX, y: baseOffset.height + rect.midY)
            return MemoryFlight(
                content: plan.content,
                tier: plan.tier,
                start: start,
                end: end,
                delay: plan.delay
            )
        }
        completedFlightIDs = []
        isPlayingIntro = true
    }

    /// Each token reports when its full flight (including the tuck-in) is done. The
    /// overlay stays up until every one has landed — no global time cap.
    private func flightCompleted(_ flight: MemoryFlight) {
        completedFlightIDs.insert(flight.id)
        guard completedFlightIDs.count >= introFlights.count else { return }
        isPlayingIntro = false
        introFlights = []
        completedFlightIDs = []
    }

    // MARK: - Layout math

    private func fitCell(_ viewport: CGSize) -> Double {
        let columns = Double(GridConstants.columnsPerYear)
        let rows = Double(rowCount)
        let gap = GridConstants.cellSpacing
        let width = (Double(viewport.width) - gap * (columns - 1)) / columns
        let height = (Double(viewport.height) - gap * (rows - 1)) / rows
        return max(min(width, height), 0.0001)
    }

    private func contentSize(viewport: CGSize, zoom: Double) -> CGSize {
        let columns = Double(GridConstants.columnsPerYear)
        let rows = Double(rowCount)
        let gap = GridConstants.cellSpacing
        let cell = fitCell(viewport) * zoom
        return CGSize(
            width: columns * cell + gap * (columns - 1),
            height: rows * cell + gap * (rows - 1)
        )
    }

    private func clampZoom(_ zoom: Double) -> Double {
        min(max(zoom, 1), GridConstants.maxZoomScale)
    }

    /// Centers content that fits, or clamps to cover the viewport when larger (so you
    /// can't pan past the edges).
    private func clampOffset(_ offset: CGSize, zoom: Double, viewport: CGSize) -> CGSize {
        let content = contentSize(viewport: viewport, zoom: zoom)
        func clamp(_ value: Double, content: Double, viewport: Double) -> Double {
            if content <= viewport { return (viewport - content) / 2 }
            return min(0, max(viewport - content, value))
        }
        return CGSize(
            width: clamp(offset.width, content: content.width, viewport: viewport.width),
            height: clamp(offset.height, content: content.height, viewport: viewport.height)
        )
    }
}
