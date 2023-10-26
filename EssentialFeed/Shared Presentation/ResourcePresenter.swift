//
//  ResourcePresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public final class ResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    private static var loadError: String {
        String(
            localized: "GENERIC_LOAD_ERROR",
            table: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Generic error message displayed when network loading fails"
        )
    }
    
    public init(
        loadingView: ResourceLoadingView,
        resourceView: View,
        errorView: ResourceErrorView,
        mapper: @escaping Mapper
    ) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didEndLoading(with resource: Resource) {
        do {
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
            resourceView.display(try mapper(resource))
        } catch {
            didEndLoading(with: error)
        }
    }
    
    public func didEndLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
