#if os(iOS) || os(tvOS)
  import UIKit

  extension Snapshotting where Value == UIView, Format == UIImage {
    /// A snapshot strategy for comparing views based on pixel equality.
    public static var image: Snapshotting {
      return .image()
    }

    /// A snapshot strategy for comparing views based on pixel equality.
    ///
    /// - Parameters:
    ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render
    ///     `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your
    ///     tests and will _not_ work for framework test targets.
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    ///
    ///   - delay: A time in seconds, for how long to wait before making snapshot
    public static func image(
      drawHierarchyInKeyWindow: Bool = false,
      precision: Float = 1,
      perceptualPrecision: Float = 0.99,
      size: CGSize? = nil,
      traits: UITraitCollection = .init(),
      delay: Double? = nil
    )
      -> Snapshotting
    {

      return SimplySnapshotting.image(
        precision: precision, perceptualPrecision: perceptualPrecision, scale: traits.displayScale
      ).asyncPullback { view in
        snapshotView(
          config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: .init()),
          drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
          traits: traits,
          view: view,
          viewController: .init(),
          delay: delay
        )
      }
    }
  }

  extension Snapshotting where Value == UIView, Format == String {
    /// A snapshot strategy for comparing views based on a recursive description of their properties
    /// and hierarchies.
    ///
    /// ``` swift
    /// s// Layout on the current device.
    /// assertSnapshot(of: view, as: .recursiveDescription)
    ///
    /// // Layout with a certain size.
    /// assertSnapshot(of: view, as: .recursiveDescription(size: .init(width: 22, height: 22)))
    ///
    /// // Layout with a certain trait collection.
    /// assertSnapshot(of: view, as: .recursiveDescription(traits: .init(horizontalSizeClass: .regular)))
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// <UIButton; frame = (0 0; 22 22); opaque = NO; layer = <CALayer>>
    ///    | <UIImageView; frame = (0 0; 22 22); clipsToBounds = YES; opaque = NO; userInteractionEnabled = NO; layer = <CALayer>>
    /// ```
    public static var recursiveDescription: Snapshotting {
      return Snapshotting.recursiveDescription()
    }

    /// A snapshot strategy for comparing views based on a recursive description of their properties
    /// and hierarchies.
    public static func recursiveDescription(
      size: CGSize? = nil,
      traits: UITraitCollection = .init()
    )
      -> Snapshotting<UIView, String>
    {
      return SimplySnapshotting.lines.pullback { view in
        let dispose = prepareView(
          config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: traits),
          drawHierarchyInKeyWindow: false,
          traits: .init(),
          view: view,
          viewController: .init()
        )
        defer { dispose() }
        return purgePointers(
          view.perform(Selector(("recursiveDescription"))).retain().takeUnretainedValue()
            as! String
        )
      }
    }
  }
#endif
