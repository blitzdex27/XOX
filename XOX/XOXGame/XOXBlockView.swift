//
//  XOXBlockView.swift
//  XOX
//
//  Created by Dexter Ramos on 10/14/23.
//

import SwiftUI

struct XOXBlockView: View {
    private let value: XOXPiece.Variation?
    
    private let location: Location
    
    private let sideLength: CGFloat
    
    typealias ImageSelection = (blank: Int, occupied: Int)
    private let imageSelection: ImageSelection
    
    typealias Handler = (_ value: String, _ location: Location) -> Void
    private let handler: Handler
    
    init?(spot: Board<XOXPiece>.Spot?, sideLength: CGFloat = 100, imageSelection: ImageSelection, handler: @escaping Handler) {
        guard let spot = spot else {
            return nil
        }
        self.value = spot.piece?.value
        self.location = spot.location
        self.sideLength = sideLength
        self.imageSelection = imageSelection
        self.handler = handler
    }
    
    var body: some View {
        Button {
            handler("x", location)
        } label: {
            imageContent
                .modifier(ColorInvertModifier())
        }

//        .frame(width: sideLength, height: sideLength)
        .aspectRatio(1, contentMode: .fit)
        .background(.gray)
        .border(.gray, width: 0.5)
        
    }
    
    private var imageContent: some View {
        
        var imageName = "dragon_\(imageSelection.blank)"
        
        guard let value = value else {
            return Image(imageName).resizable()
        }
        
        switch value {
        case .x:
            imageName = "x_\(imageSelection.occupied)"
        case .o:
            imageName = "o_\(imageSelection.occupied)"
        default:
            imageName = "dragon_\(imageSelection.blank)"
        }
        return Image(imageName)
            .resizable()
    }
}



struct ColorInvertModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    private var isReversed: Bool
    
    init(isReversed: Bool = false) {
        self.isReversed = isReversed
    }
    
    func body(content: Content) -> some View {
        
        if isReversed {
            switch colorScheme {
            case .dark:
                content
            case .light:
                content.colorInvert()
            default:
                content
            }
        } else {
            switch colorScheme {
            case .dark:
                content.colorInvert()
            case .light:
                content
            default:
                content
            }
        }


    }
    
}
