//
//  HomePageViewModel.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol HomePageViewModelInputs {
    
    func configureWith()
    
    /// Call when the filter is changed.
    func selectedFilter(_ params: ExploreParams)
    
    /// Call when the project navigator has transitioned to a new project with its index.
    func transitionedToProject(at row: Int, outOf totalRows: Int)
    
    /// Call when the controller has received a user session ended notification.
    func userSessionEnded()
    
    /// Call when the controller has received a user session started notification.
    func userSessionStarted()
    
    /// Call when the view appears.
    func viewDidAppear()
    
    /// Call when the view disappears.
    func viewDidDisappear(animated: Bool)
    
    /// Call when the view will appear.
    func viewWillAppear()
    
    /**
     Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.
     
     - parameter row:       The 0-based index of the row displaying.
     - parameter totalRows: The total number of rows in the table view.
     */
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol HomePageViewModelOutputs {
    var asyncReloadData: Signal<Void, NoError> { get }
    var wordsAreLoading: Signal<Bool, NoError> { get }
    /// Emits a list of projects that should be shown.
    var words: Signal<[Word], NoError> { get }
}

public protocol HomePageViewModelType {
    var inputs: HomePageViewModelInputs { get }
    var outputs: HomePageViewModelOutputs { get }
}

public final class HomePageViewModel: HomePageViewModelType, HomePageViewModelInputs,
HomePageViewModelOutputs {
    
    // swiftlint:disable function_body_length
    public init() {
        let currentUser = Signal.merge(
            self.userSessionStartedProperty.signal,
            self.userSessionEndedProperty.signal,
            self.viewDidAppearProperty.signal
            )
            .map { AppEnvironment.current.currentUser }
            .skipRepeats(==)
        
        let isVisible = Signal.merge(
            self.viewDidAppearProperty.signal.mapConst(true),
            self.viewDidDisappearProperty.signal.mapConst(false)
            ).skipRepeats()
        
        let isCloseToBottom = Signal.merge(
            self.willDisplayRowProperty.signal.skipNil(),
            self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
            )
            .map { row, total in
                row >= total - 3 && row > 0
            }
            .skipRepeats()
            .filter(isTrue)
            .ignoreValues()
        
        let requestFirstPageWith = Signal.combineLatest(currentUser, isVisible)
            .filter { _, visible in visible }
            .skipRepeats { lhs, rhs in lhs.0 == rhs.0 && lhs.1 == rhs.1 }
            .map(second)
        
        let paginatedWords: Signal<[Word], NoError>
        let pageCount: Signal<Int, NoError>
        (paginatedWords, self.wordsAreLoading, pageCount) = paginate(
            requestFirstPageWith: requestFirstPageWith,
            requestNextPageWhen: isCloseToBottom,
            clearOnNewRequest: false,
            skipRepeats: false,
            valuesFromEnvelope: { $0.words },
            cursorFromEnvelope: { $0.urls.api.moreWords },
            requestFromParams: { _ in AppEnvironment.current.apiService.fetchExplore(params: ExploreParams(selected: true, created: true)) },
            requestFromCursor: { _ in AppEnvironment.current.apiService.fetchExplore(paginationUrl: "ddd") },
            concater: { ($0 + $1).distincts() })
        
        self.words = Signal.merge(
            paginatedWords,
            self.selectedFilterProperty.signal.skipNil().skipRepeats().mapConst([])
            )
            .skip { $0.isEmpty }
            .skipRepeats(==)
        
        self.asyncReloadData = self.words.take(first: 1).ignoreValues()
    }
    // swiftlint:enable function_body_length
    
    fileprivate let sortProperty = MutableProperty()
    public func configureWith() {
        self.sortProperty.value = ()
    }
    fileprivate let selectedFilterProperty = MutableProperty<ExploreParams?>(nil)
    public func selectedFilter(_ params: ExploreParams) {
        self.selectedFilterProperty.value = params
    }
    private let transitionedToProjectRowAndTotalProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func transitionedToProject(at row: Int, outOf totalRows: Int) {
        self.transitionedToProjectRowAndTotalProperty.value = (row, totalRows)
    }
    fileprivate let userSessionStartedProperty = MutableProperty()
    public func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty()
    public func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    fileprivate let viewDidAppearProperty = MutableProperty()
    public func viewDidAppear() {
        self.viewDidAppearProperty.value = ()
    }
    fileprivate let viewDidDisappearProperty = MutableProperty(false)
    public func viewDidDisappear(animated: Bool) {
        self.viewDidDisappearProperty.value = animated
    }
    fileprivate let viewWillAppearProperty = MutableProperty()
    public func viewWillAppear() {
        self.viewWillAppearProperty.value = ()
    }
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let words: Signal<[Word], NoError>
    public let asyncReloadData: Signal<Void, NoError>
    public let wordsAreLoading: Signal<Bool, NoError>
    
    
    public var inputs: HomePageViewModelInputs { return self }
    public var outputs: HomePageViewModelOutputs { return self }
}

