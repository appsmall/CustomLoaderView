//
//  CustomLoaderView.swift
//  CustomLoaderView
//
//  Created by Rahul Chopra on 28/08/18.
//  Copyright © 2018 Appsmall. All rights reserved.
//

import UIKit

class CustomLoaderView {
    
    private init() {}
    
    private static var sharedInstance: CustomLoaderView?
    
    static func shared() -> CustomLoaderView {
        guard let share = sharedInstance else {
            sharedInstance = CustomLoaderView()
            return sharedInstance!
        }
        return share
    }
    
    
    private var overlayView: UIView?
    private var contentRootView: UIView?
    private var contentView: UIView?
    private var indicator: UIActivityIndicatorView?
    
    
    private var loaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        return view
    }()
    
    private var loaderSubview: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.purple
        view.layer.cornerRadius = 32.5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Please wait..."
        label.textColor = UIColor.black
        label.font = UIFont.init(name: "GillSans-SemiBold", size: 20)
        label.numberOfLines = 1
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    private var subHeadingLabel: UILabel = {
        let label = UILabel()
        label.text = "While we fetching your data from the server."
        label.textColor = UIColor.darkGray
        label.font = UIFont.init(name: "GillSans-SemiBold", size: 16)
        label.numberOfLines = 2
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    
    
    // MARK:- SHOW AND HIDE ALL UIVIEWs
    
    // Using this function in another ViewController class, we can use all the CustomLoaderView class properties.
    func show(indicatorStyle: UIActivityIndicatorViewStyle?, headingText: String?, subHeadingText: String?) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        adjustBackgroundView(overlayTarget: window)
        changeContentDataAccToUserReq(indicatorStyle: indicatorStyle, headingText: headingText, subHeadingText: subHeadingText)
    }
    
    // Hide and Remove all UIViews with Animation
    func hide() {
        if let contentRootView = contentRootView {
            UIView.animate(withDuration: 1.0, animations: {
                contentRootView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }) { (completed) in
                if completed {
                    if self.overlayView != nil {
                        self.loaderView.removeFromSuperview()
                        self.loaderSubview.removeFromSuperview()
                        self.contentView?.removeFromSuperview()
                        self.overlayView?.removeFromSuperview()
                        self.indicator?.removeFromSuperview()
                        self.indicator = nil
                        self.contentView = nil
                        self.overlayView = nil
                    }
                }
            }
        }
    }
    
    // MARK:- SELECTOR ACTION METHOD
    // This function gets called when we tapped on OverlayView
    @objc private  func backgroundTapped() {
        hide()
    }
    
    // MARK:- CHANGE CONTENT DATA ACCORDING TO USER REQUIREMENT
    // Change Content according to User Requirement
    private func changeContentDataAccToUserReq(indicatorStyle: UIActivityIndicatorViewStyle?, headingText: String?, subHeadingText: String?) {
        if indicatorStyle == nil {
            print("User send nil value, it shows whiteLarge Indicator Style")
        } else {
            indicator?.activityIndicatorViewStyle = indicatorStyle!
        }
        
        if headingText == nil && subHeadingText == nil {
            print("User send nil values, it shows by default set values")
        } else {
            headingLabel.text = headingText
            subHeadingLabel.text = subHeadingText
        }
    }
    
    // MARK:- CORE FUNCTIONS
    // creates a view of screen window size (on whole screen)
    private func createOverlayView(overlayTargetView: UIView, backgroundColor: UIColor, alpha: CGFloat) -> UIView {
        let overlay = UIView(frame: overlayTargetView.frame)
        overlay.center = overlayTargetView.center
        overlay.alpha = alpha
        overlay.backgroundColor = backgroundColor
        return overlay
    }
    
    //Show Background OverlayView and ContentView
    private func adjustBackgroundView(overlayTarget: UIView) {
        overlayView = createOverlayView(overlayTargetView: overlayTarget, backgroundColor: UIColor.black, alpha: 0.5)
        
        if let overlayView = overlayView {
            overlayTarget.addSubview(overlayView)
            overlayTarget.bringSubview(toFront: overlayView)
            
            // Hide all UIViews when tapped on OverlayView
            let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
            overlayView.addGestureRecognizer(tap)
            
            
            contentRootView = createOverlayView(overlayTargetView: overlayTarget, backgroundColor: UIColor.clear, alpha: 1.0)
            if let contentRootView = contentRootView {
                overlayTarget.addSubview(contentRootView)
                setupContentRootViewConstraints(contentRootView: contentRootView, overlayView: overlayView)
                
                //Set ContentRootView Tranform Scale to (0,0)
                contentRootView.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                //Animation for ContentRootView and Move ContentRootView to its original position i.e. (1,1).
                UIView.animate(withDuration: 1.0, animations: {
                    contentRootView.transform = CGAffineTransform.identity
                }, completion: nil)
                
                // Create and Show ContentView
                contentView = createOverlayView(overlayTargetView: overlayTarget, backgroundColor: UIColor.white, alpha: 1.0)
                if let contentView = contentView {
                    contentRootView.addSubview(contentView)
                    
                    //Add borderColor, borderWidth and cornerRadius to ContentView
                    contentView.layer.borderColor = UIColor.black.cgColor
                    contentView.layer.borderWidth = 1.0
                    contentView.layer.cornerRadius = 8.0
                    contentView.layer.masksToBounds = true
                    
                    setupContentViewConstraints(contentView: contentView, contentRootView: contentRootView)
                    updateContentOnContentView(contentView: contentView)
                    
                    // Add LoaderView and ActivityIndicator
                    addLoaderViewAndIndicator(contentRootView: contentRootView, contentView: contentView)
                }
            }
        }
    }
    
    // MARK:- SETUP CONSTRAINTS
    // SETUP CONTENTROOTVIEW CONSTRAINTS
    private func setupContentRootViewConstraints(contentRootView: UIView, overlayView: UIView) {
        contentRootView.translatesAutoresizingMaskIntoConstraints = false
        contentRootView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        contentRootView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        contentRootView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        contentRootView.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    // SETUP CONTENTVIEW CONSTRAINTS
    private func setupContentViewConstraints(contentView: UIView, contentRootView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.centerXAnchor.constraint(equalTo: contentRootView.centerXAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: contentRootView.bottomAnchor, constant: 0).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    // SETUP CONTENTS CONSTRAINTS WITHIN CONTENTVIEW
    private func updateContentOnContentView(contentView: UIView) {
        contentView.addSubview(headingLabel)
        contentView.addSubview(subHeadingLabel)
        
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        headingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        headingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -2).isActive = true
        
        subHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 5).isActive = true
        subHeadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        subHeadingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    //MARK:- ADD LOADERVIEW, ACTIVITY INDICATOR AND SETUP CONSTRAINTS
    private func addLoaderViewAndIndicator(contentRootView: UIView, contentView: UIView) {
        //Add Loader View and Setup Loader View Constraints
        contentRootView.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        loaderView.widthAnchor.constraint(equalTo: loaderView.heightAnchor).isActive = true
        loaderView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        setSemiCircleShapeToView(semiCircleView: loaderView)
        
        loaderView.addSubview(loaderSubview)
        loaderSubview.translatesAutoresizingMaskIntoConstraints = false
        loaderSubview.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true
        loaderSubview.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor).isActive = true
        loaderSubview.heightAnchor.constraint(equalToConstant: 65).isActive = true
        loaderSubview.widthAnchor.constraint(equalTo: loaderSubview.heightAnchor).isActive = true
        
        //Add Activity Indicator Object
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator?.center = loaderSubview.center
        indicator?.startAnimating()
        loaderSubview.addSubview(indicator!)
        
        //Setup Activity Indicator Constraints
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        indicator?.centerXAnchor.constraint(equalTo: loaderSubview.centerXAnchor).isActive = true
        indicator?.centerYAnchor.constraint(equalTo: loaderSubview.centerYAnchor).isActive = true
    }
    
    // MARK:- CREATE SEMI-CIRCLE SHAPE OF UIVIEW
    // Using Add Shape Layer
    private func setSemiCircleShapeToView(semiCircleView: UIView) {
        semiCircleView.layoutIfNeeded()
        
        let center = CGPoint(x: semiCircleView.frame.size.width / 2, y: semiCircleView.frame.size.height / 2)
        let circleRadius = semiCircleView.frame.size.width / 2
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: .pi, endAngle: (.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        semiCircleView.layer.addSublayer(shapeLayer)
    }
}
