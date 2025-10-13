//
//  ScrollViewWithDelegate.swift
//  OtoTheory
//
//  ScrollView with UIScrollViewDelegate for detecting scroll direction
//

import SwiftUI
import UIKit

struct ScrollViewWithDelegate<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let onScroll: (CGFloat) -> Void
    
    init(@ViewBuilder content: () -> Content, onScroll: @escaping (CGFloat) -> Void) {
        self.content = content()
        self.onScroll = onScroll
    }
    
    func makeUIViewController(context: Context) -> ScrollViewController<Content> {
        let viewController = ScrollViewController(content: content, onScroll: onScroll)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ScrollViewController<Content>, context: Context) {
        uiViewController.updateContent(content)
    }
}

class ScrollViewController<Content: View>: UIViewController, UIScrollViewDelegate {
    private var scrollView: UIScrollView!
    private var hostingController: UIHostingController<Content>!
    private var lastContentOffset: CGFloat = 0
    private let onScroll: (CGFloat) -> Void
    
    init(content: Content, onScroll: @escaping (CGFloat) -> Void) {
        self.onScroll = onScroll
        super.init(nibName: nil, bundle: nil)
        
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        
        // Create hosting controller
        hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        // Update hosting controller size
        let contentSize = hostingController.view.intrinsicContentSize
        hostingController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: contentSize.height)
        scrollView.contentSize = hostingController.view.frame.size
    }
    
    func updateContent(_ content: Content) {
        hostingController.rootView = content
        view.setNeedsLayout()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let delta = currentOffset - lastContentOffset
        
        // Call the callback with scroll delta
        onScroll(delta)
        
        lastContentOffset = currentOffset
    }
}

