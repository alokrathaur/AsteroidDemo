//
//  SwiftLoader.swift
//  AsteroidGraphApp
//
//  Created by ALOK on 25/11/22.
//

import Foundation
import UIKit
import QuartzCore
import CoreGraphics

let loaderSpinnerMarginSide : CGFloat = 35.0
let loaderSpinnerMarginTop : CGFloat = 20.0
let loaderTitleMargin : CGFloat = 5.0

public class SwiftLoader: UIView {
    
    private var coverView : UIView?
    private var titleLabel : UILabel?
    var loadingView : SwiftLoadingView?
    private var animated : Bool = true
    private var canUpdated = false
    private var title: String?
    private var speed = 1
    
    private var config : Config = Config() {
        didSet {
            self.loadingView?.config = config
        }
    }
    
    @objc func rotated(notification: NSNotification) {
        
        let loader = SwiftLoader.sharedInstance
        
        let height : CGFloat = UIScreen.main.bounds.size.height
        let width : CGFloat = UIScreen.main.bounds.size.width
        let center : CGPoint = CGPoint(x: width / 2.0, y: height / 2.0)
        
        loader.center = center
        loader.coverView?.frame = UIScreen.main.bounds
    }
    
    override public var frame : CGRect {
        didSet {
            self.update()
        }
    }
    
    class var sharedInstance: SwiftLoader {
        struct Singleton {
            static let instance = SwiftLoader(frame: CGRect(origin: CGPoint(x: 0,y: 0),size: CGSize(width: Config().size,height: Config().size)))
        }
        return Singleton.instance
    }
    
    public class func show(animated: Bool) {
        
        let loader = SwiftLoader.sharedInstance
        loader.config.backgroundColor = UIColor.black
        loader.config.spinnerColor = UIColor(red:80.0/255.0, green:158.0/255.0, blue:129.0/255.0, alpha:1)
        loader.config.titleTextColor = UIColor(red:0.88, green:0.26, blue:0.18, alpha:1)
        loader.config.spinnerLineWidth = 2.0
        loader.config.foregroundColor = UIColor.black
        loader.config.foregroundAlpha = 0.8
        
        self.show(title: nil, animated: animated)
    }
    
    public class func show(title: String?, animated : Bool) {
        
        let currentWindow : UIWindow = UIApplication.shared.keyWindow!
        
        let loader = SwiftLoader.sharedInstance
        loader.canUpdated = true
        loader.animated = animated
        loader.title = title
        loader.update()
        
        NotificationCenter.default.addObserver(loader, selector: #selector(loader.rotated(notification: )),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        let height : CGFloat = UIScreen.main.bounds.size.height
        let width : CGFloat = UIScreen.main.bounds.size.width
        let center : CGPoint = CGPoint(x: width / 2.0, y: height / 2.0)
        
        loader.center = center
        
        if (loader.superview == nil) {
            loader.coverView = UIView(frame: currentWindow.bounds)
            loader.coverView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            currentWindow.addSubview(loader.coverView!)
            currentWindow.addSubview(loader)
            loader.start()
        }
    }
    
    public class func hide() {
        
        let loader = SwiftLoader.sharedInstance
        NotificationCenter.default.removeObserver(loader)
        
        loader.stop()
    }
    
    public class func setConfig(config : Config) {
        let loader = SwiftLoader.sharedInstance
        loader.config = config
        loader.frame = CGRect(origin: CGPoint(x: 0, y: 0),size: CGSize(width: loader.config.size, height: loader.config.size))
    }
    
    /**
     Private methods
     */
    
    private func setup() {
        self.alpha = 0
        self.update()
    }
    
    private func start() {
        self.loadingView?.start()
        
        if (self.animated) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1
            }, completion: { (finished) -> Void in
                
            });
        } else {
            self.alpha = 1
        }
    }
    
    private func stop() {
        
        if (self.animated) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 0
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
                self.coverView?.removeFromSuperview()
                self.loadingView?.stop()
            });
        } else {
            self.alpha = 0
            self.removeFromSuperview()
            self.coverView?.removeFromSuperview()
            self.loadingView?.stop()
        }
    }
    
    
    private func update() {
        self.backgroundColor = self.config.backgroundColor
        
       let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        //   gradient.colors = [UIColor.init(red: 0/255.0, green: 82/255.0, blue: 161/255.0, alpha: 1.0).cgColor, UIColor.init(red: 22/255.0, green: 155/255.0, blue: 226/255.0, alpha: 1.0).cgColor]
        gradient.colors = [UIColor.gray.cgColor, UIColor.gray.cgColor]
        
        gradient.startPoint = CGPoint.init(x: 0.0, y: 1)
        gradient.endPoint = CGPoint.init(x: 1.0, y: 0.9)
        self.layer.insertSublayer(gradient, at: 0)
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true
        
        self.layer.cornerRadius = self.config.cornerRadius
        let loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.loadingView == nil) {
            self.loadingView = SwiftLoadingView(frame: self.frameForSpinner())
            self.addSubview(self.loadingView!)
        } else {
            self.loadingView?.frame = self.frameForSpinner()
        }
        
        if (self.titleLabel == nil) {
            self.titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: loaderTitleMargin, y: loaderSpinnerMarginTop + loadingViewSize), size: CGSize(width: self.frame.width - loaderTitleMargin*2, height:  42.0)))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.textAlignment = NSTextAlignment.center
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        } else {
            self.titleLabel?.frame = CGRect(origin: CGPoint(x: loaderTitleMargin, y: loaderSpinnerMarginTop + loadingViewSize), size: CGSize(width: self.frame.width - loaderTitleMargin*2, height: 42.0))
        }
        
        self.titleLabel?.font = self.config.titleTextFont
        self.titleLabel?.textColor = self.config.titleTextColor
        self.titleLabel?.text = self.title
        
        self.titleLabel?.isHidden = self.title == nil
    }
    
    func frameForSpinner() -> CGRect {
        let loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.title == nil) {
            let yOffset = (self.frame.size.height - loadingViewSize) / 2
            return CGRect(origin: CGPoint(x: loaderSpinnerMarginSide, y: yOffset), size: CGSize(width: loadingViewSize , height: loadingViewSize))
        }
        return CGRect(origin: CGPoint(x: loaderSpinnerMarginSide, y: loaderSpinnerMarginTop), size: CGSize(width: loadingViewSize, height: loadingViewSize))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     *  Loader View
     */
    class SwiftLoadingView : UIView {
        
        private var speed : Int?
        private var lineWidth : Float?
        private var lineTintColor : UIColor?
        private var backgroundLayer : CAShapeLayer?
        private var isSpinning : Bool?
        
        var config : Config = Config() {
            didSet {
                self.update()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        /**
         Setup loading view
         */
        
        func setup() {
            self.backgroundColor = UIColor.clear
            self.lineWidth = fmaxf(Float(self.frame.size.width) * 0.025, 1)
            
            self.backgroundLayer = CAShapeLayer()
            self.backgroundLayer?.strokeColor = self.config.spinnerColor.cgColor
            self.backgroundLayer?.fillColor = self.backgroundColor?.cgColor
            self.backgroundLayer?.lineCap = CAShapeLayerLineCap.round
            self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
            self.layer.addSublayer(self.backgroundLayer!)
        }
        
        func update() {
            self.lineWidth = self.config.spinnerLineWidth
            self.speed = self.config.speed
            
            self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
            self.backgroundLayer?.strokeColor = self.config.spinnerColor.cgColor
        }
        
        /**
         Draw Circle
         */
        
        override func draw(_ rect: CGRect) {
            self.backgroundLayer?.frame = self.bounds
        }
        
        func drawBackgroundCircle(partial : Bool) {
            let startAngle : CGFloat = .pi / CGFloat(2.0)
            var endAngle : CGFloat = (2.0 * .pi) + startAngle
            
            let center : CGPoint = CGPoint(x: self.bounds.size.width / 2,y: self.bounds.size.height / 2)
            let radius : CGFloat = (CGFloat(self.bounds.size.width) - CGFloat(self.lineWidth!)) / CGFloat(2.0)
            
            let processBackgroundPath : UIBezierPath = UIBezierPath()
            processBackgroundPath.lineWidth = CGFloat(self.lineWidth!)
            
            if (partial) {
                endAngle = (1.8 * .pi) + startAngle
            }
            
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            self.backgroundLayer?.path = processBackgroundPath.cgPath;
        }
        
        /**
         Start and stop spinning
         */
        
        func start() {
            self.isSpinning? = true
            self.drawBackgroundCircle(partial: true)
            
            let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
            rotationAnimation.duration = 1;
            rotationAnimation.isCumulative = true;
            rotationAnimation.repeatCount = HUGE;
            self.backgroundLayer?.add(rotationAnimation, forKey: "rotationAnimation")
        }
        
        func stop() {
            self.drawBackgroundCircle(partial: false)
            
            self.backgroundLayer?.removeAllAnimations()
            self.isSpinning? = false
        }
    }
    
    
    /**
     * Loader config
     */
    public struct Config {
        
        /**
         *  Size of loader
         */
        public var size : CGFloat = 100.0
        
        /**
         *  Color of spinner view
         */
        public var spinnerColor = UIColor.white
        
        /**
         *  S
         */
        public var spinnerLineWidth :Float = 2.0
        
        /**
         *  Color of title text
         */
        public var titleTextColor = UIColor.white
        
        /**
         *  Speed of the spinner
         */
        public var speed :Int = 1
        
        /**
         *  Font for title text in loader
         */
        public var titleTextFont : UIFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /**
         *  Background color for loader
         */
        public var backgroundColor = UIColor.white
        
        /**
         *  Foreground color
         */
        public var foregroundColor = UIColor.clear
        
        /**
         *  Foreground alpha CGFloat, between 0.0 and 1.0
         */
        public var foregroundAlpha:CGFloat = 0.0
        
        /**
         *  Corner radius for loader
         */
        public var cornerRadius : CGFloat = 10.0
        
        public init() {}
        
    }
}

