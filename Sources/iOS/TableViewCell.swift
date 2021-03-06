/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

open class TableViewCell: UITableViewCell, Pulseable {
    /**
     A CAShapeLayer used to manage elements that would be affected by
     the clipToBounds property of the backing layer. For example, this
     allows the dropshadow effect on the backing layer, while clipping
     the image to a desired shape within the visualLayer.
     */
    open fileprivate(set) var visualLayer = CAShapeLayer()
    
    /// A Pulse reference.
    open fileprivate(set) var pulse: Pulse!
    
    /// PulseAnimation value.
    open var pulseAnimation: PulseAnimation {
        get {
            return pulse.animation
        }
        set(value) {
            pulse.animation = value
        }
    }
    
    /// PulseAnimation color.
    @IBInspectable
    open var pulseColor: UIColor {
        get {
            return pulse.color
        }
        set(value) {
            pulse.color = value
        }
    }
    
    /// Pulse opacity.
    @IBInspectable
    open var pulseOpacity: CGFloat {
        get {
            return pulse.opacity
        }
        set(value) {
            pulse.opacity = value
        }
    }
    
	/// A property that accesses the backing layer's background
	@IBInspectable
    open override var backgroundColor: UIColor? {
		didSet {
			layer.backgroundColor = backgroundColor?.cgColor
		}
	}
	
	/**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		prepare()
	}
	
	/**
     An initializer that initializes the object.
     - Parameter style: A UITableViewCellStyle enum.
     - Parameter reuseIdentifier: A String identifier.
     */
	public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		prepare()
	}
	
	open override func layoutSublayers(of layer: CALayer) {
		super.layoutSublayers(of: layer)
        layoutShape()
        layoutVisualLayer()
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		layoutShadowPath()
	}
	
    /**
     Triggers the pulse animation.
     - Parameter point: A Optional point to pulse from, otherwise pulses
     from the center.
     */
    open func pulse(point: CGPoint? = nil) {
        let p = nil == point ? CGPoint(x: CGFloat(width / 2), y: CGFloat(height / 2)) : point!
        
        pulse.expandAnimation(point: p)
        Motion.delay(time: 0.35) { [weak self] in
            guard let s = self else {
                return
            }
            s.pulse.contractAnimation()
        }
    }
    
    /**
     A delegation method that is executed when the view has began a
     touch event.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pulse.expandAnimation(point: layer.convert(touches.first!.location(in: self), from: layer))
    }
    
    /**
     A delegation method that is executed when the view touch event has
     ended.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pulse.contractAnimation()
    }
    
    /**
     A delegation method that is executed when the view touch event has
     been cancelled.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pulse.contractAnimation()
    }
	
	/**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepare method
     to initialize property values and other setup operations.
     The super.prepare method should always be called immediately
     when subclassing.
     */
	open func prepare() {
		selectionStyle = .none
		separatorInset = .zero
		contentScaleFactor = Device.scale
		imageView?.isUserInteractionEnabled = false
		textLabel?.isUserInteractionEnabled = false
		detailTextLabel?.isUserInteractionEnabled = false
		prepareVisualLayer()
        preparePulse()
	}
}

extension TableViewCell {
    /// Prepares the pulse motion.
    fileprivate func preparePulse() {
        pulse = Pulse(pulseView: self, pulseLayer: visualLayer)
    }
    
    /// Prepares the visualLayer property.
    fileprivate func prepareVisualLayer() {
        visualLayer.zPosition = 0
        visualLayer.masksToBounds = true
        contentView.layer.addSublayer(visualLayer)
    }
}

extension TableViewCell {
    /// Manages the layout for the visualLayer property.
    fileprivate func layoutVisualLayer() {
        visualLayer.frame = bounds
        visualLayer.cornerRadius = cornerRadius
    }
}
