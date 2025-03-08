//import SwiftUI
//
//struct HeroSection: View {
//    //value
//    let frameHeight : CGFloat = 200
//    
//    //init value
//    @State private var imageWidth: CGFloat = 0
//    @State private var initMinY : CGFloat = 0
//    
//    //state value
//    @State private var imageOpacity : Double = 1
//    @State private var currentHeight : CGFloat = 0
//
//    var body: some View {
//        ZStack {
//            GeometryReader { proxy in
//                let minY = proxy.frame(in: .global).minY
//                let midX = proxy.frame(in: .global).midX
//                
//                Image("sunny")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: imageWidth, height: frameHeight + (minY > 0 ? minY : 0), alignment: .bottom)
//                    .offset(x: -midX + imageWidth / 2, y: minY > 0 ? -minY : 0)
//                    .opacity(imageOpacity)
//                    .onChange(of: minY) { _, newValue in
//                        if initMinY > newValue {
//                            imageOpacity = circulateOpacity(initOffset: initMinY, initHeight: frameHeight, newValue: newValue)
//                        }
//                    }
//                    .onAppear {
//                        imageWidth = proxy.size.width
//                        initMinY = minY
//                        print(minY)
//                    }
//            }
//        }
//        .frame(height: frameHeight)
//    }
//    
//    func circulateOpacity(initOffset: CGFloat, initHeight: CGFloat, newValue: CGFloat) -> Double {
//        let totalHeight = initHeight + initOffset
//        let imageOpacity : Double = newValue > 0 ? 1 - (totalHeight - (initHeight + newValue))/totalHeight : 1 - (totalHeight - (initHeight + newValue))/totalHeight
//        return imageOpacity
//    }
//}
//
//struct HeroSectionView: View {
//    var body: some View {
//        ScrollView {
//                HeroSection()
//                ForEach(1..<20) { index in
//                    Text("Content \(index)")
//                        .padding()
//                }
//            
//        }
//    }
//}
//
//#Preview {
//    HeroSectionView()
//}
