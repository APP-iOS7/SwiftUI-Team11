/*
 Version : 1_0_1
 Date    : 2025-03-08(SAT)
 Log     : Poster Detail View Draft and Hero Section didn't show image bugfix
 */

import SwiftUI
import UIKit

struct posterItemDetailView: View {
    @State private var isBookmarked : Bool = false
    
    var heroSectionHeight : CGFloat
    var moiveId : Int
    var rating : Double
    
    init(movieId: Int, rating: Double = 0, _ heroSectionHeight: CGFloat = 230) {
        self.heroSectionHeight = heroSectionHeight
        self.moiveId = movieId
        self.rating = rating
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                HeroSection(frameHeight: heroSectionHeight)
                Spacer(minLength: 40)
                ratingView()
                    .frame(height: 50)
                Spacer(minLength: 30)
                buttonView
                Spacer(minLength: 34)
                Divider()
                Spacer(minLength: 11)
                detailView()
                Spacer()
            }
        }
    }
    
    var buttonView : some View {
        HStack(spacing: 47) {
            Button(
                action: {
                    bookmarkedButtonClicked()
                },
                label: {
                    HStack{
                        Image(systemName: isBookmarked ? "suit.heart.fill" : "plus")
                        Text("보고 싶어요!")
                            .font(.system(size: 18, weight: .bold))
                    }
            })
            .frame(width: 140, height: 50)
            .background(isBookmarked ? ColorConfig.commonYello.value() : ColorConfig.commonGrey.value())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.black)
            Button(
                action: {
//                    createCommentView()
                },
                label: {
                    Text("코멘트")
                        .font(.system(size: 18, weight: .bold))
                })
            .frame(width: 140, height: 50)
            .foregroundStyle(.black)
            .background(ColorConfig.commonGrey.value())
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    func bookmarkedButtonClicked() {
        isBookmarked.toggle()
    }
}

struct HeroSection: View {
    //init value
    var frameHeight : CGFloat
    
    init(frameHeight : CGFloat) {
        self.frameHeight = frameHeight
    }
    
    @State private var imageWidth: CGFloat = 0
    @State private var initMinY : CGFloat = 0
    
    //state value
    @State private var imageOpacity : Double = 1

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .global).minY
                let midX = proxy.frame(in: .global).midX
                
                Image("testImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageWidth, height: frameHeight + (minY > 0 ? minY : 0), alignment: .bottom)
                    .offset(x: -midX + imageWidth / 2, y: minY > 0 ? -minY : 0)
                    .opacity(imageOpacity)
                    .onChange(of: minY) { _, newValue in
                        if initMinY > newValue {
                            imageOpacity = circulateOpacity(initOffset: initMinY, initHeight: frameHeight, newValue: newValue)
                        }
                        if newValue == initMinY {
                            imageOpacity = 1.0
                        }
                    }
                    .onAppear {
                        imageWidth = proxy.size.width
                        initMinY = minY
                    }
            }
            VStack {
                Spacer()
                HStack(spacing: PaddingConfig.heroSectionHorizonSpacing.value()) {
                    Image("testImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 105)
                    VStack(alignment: .leading ,spacing: PaddingConfig.heroSectionVerticalSpacing.value()) {
                        Text("Movie Title")
                            .font(.system(size: PaddingConfig.heroSectionTitle.value(), weight: .bold))
                            .foregroundStyle(ColorConfig.heroSectionTitle.value())
                        Text("year/kinds")
                            .font(.system(size: PaddingConfig.heroSectionSubTitle.value()))
                            .foregroundStyle(ColorConfig.commonGrey.value())
                    }
                }
            }
            .padding([.leading, .trailing], PaddingConfig.sidePadding.value())
            .padding(.bottom, PaddingConfig.heroSectionBottomPadding.value())
            .opacity(imageOpacity)
        }
        .frame(height: frameHeight)
    }
    
    func circulateOpacity(initOffset: CGFloat, initHeight: CGFloat, newValue: CGFloat) -> Double {
        let totalHeight = initHeight + initOffset
        let imageOpacity : Double = newValue > 0 ? 1 - (totalHeight - (initHeight + newValue))/totalHeight : 1 - (totalHeight - (initHeight + newValue))/totalHeight
        return imageOpacity
    }
}

struct ratingView: View {
    @State private var rating: Double = 0.0
    @State private var starView: makeStarView?
    @State private var isDoubleTapped: Bool = false
    
    
    var body: some View {
        if let starView = starView {
            starView
                .onAppear {
                    self.starView = makeStarView(rating : $rating, isDoubleTapped: $isDoubleTapped)
                }
        }
        else {
            makeStarView(rating: $rating, isDoubleTapped: $isDoubleTapped)
        }
    }
}

struct makeStarView: View {
    @Binding var rating : Double
    @Binding var isDoubleTapped: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                ForEach(1..<6) { currentIterationCount in
                    if currentIterationCount <= Int(floor(rating)) {
                        starView(systemName: "star.fill", index: currentIterationCount)
                            .foregroundStyle(.black)
                    }
                    else if (rating + 1.0) > Double(currentIterationCount)  && Double(currentIterationCount) >= rating  && rating != 0 {
                        starView(systemName: "star.leadinghalf.filled", index : currentIterationCount)
                            .foregroundStyle(.black)
                    }
                    else {
                        starView(systemName: "star", index : currentIterationCount)
                            .foregroundStyle(ColorConfig.commonGrey.value())
                    }
                }
                Spacer()
            }
            .onChange(of: rating) {
                if rating == 0.5 {
                    isDoubleTapped = true
                }
                else {
                    isDoubleTapped = false
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let initGeometry = geometry.frame(in: .local).width - 50
                        let currentPosition = value.location.x - 25
                        let result = Int(currentPosition).quotientAndRemainder(dividingBy: Int(initGeometry)/10)
                        if result.quotient < 0 {
                            rating = 0
                        }
                        else if result.quotient == 0 && result.remainder < 0 {
                            rating = 0
                        }
                        else if result.quotient > 10 {
                            rating = 5
                        }
                        else {
                            rating = Double(result.quotient + 1)/2.0
                        }
                    }
            )
        }
        .padding(.horizontal, PaddingConfig.sidePadding.value())
    }
    
    func starView(systemName : String, index : Int) -> some View {
        ZStack {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            HStack(spacing: 0) {
                Button(" ") {
                    changeRating(Double(index) - 0.5)
                    if isDoubleTapped {
                        changeRating(0.0)
                        isDoubleTapped = false
                    }
                }
                .frame(width: 25, height: 50)
                Button(" ") {
                    changeRating(Double(index))
                }
                .frame(width: 25, height: 50)
            }
            .frame(width: 50, height: 50)
        }
    }
    
    func changeRating(_ newRating: Double) {
        rating = newRating
    }
}

//정보 표시 수정 필요
struct detailView: View {
    @State private var lineLimit: Int? = 3
    @State private var isLineLimitUpper : Bool = false
    @State private var textWidth : CGFloat = 0
    
    let items = ["감독", "상영 시간", "연령 등급", "장르", "제작 국가", "제작 연도", "기타1", "기타2"]
    let maxVisibleItems : Int = 4
    let dummyContents : String = "jdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjnsjdknsajacjkwkqjjkajcnjdzjfnjkqehrkqekfnkjsnfbhjzbjzgrb,jbjhzgbjbhffbjgbdfhjbgjdbjfnkjsnknfjensfkjnsjdnfnsjeejkgbsfbjjfdjknsfjns"
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    Text("개요")
                        .font(.system(size: 15, weight: .bold))
                        .onAppear() {
                            self.textWidth = geometry.frame(in: .local).width
                            let lineValue : Double = getLineValue(text: dummyContents, font: UIFont.systemFont(ofSize: 13), width: textWidth)
                            if lineValue > 3 {
                                isLineLimitUpper = true
                            }
                            else {
                                isLineLimitUpper = false
                            }
                        }
                }
                .frame(height: 12)
                Spacer(minLength: 11)
                
                    ZStack(alignment: .bottomTrailing) {
                        Text(dummyContents)
                            .font(.system(size: 13))
                            .lineLimit(lineLimit)
                        if isLineLimitUpper {
                            Button(action: {
                                if self.lineLimit == 3 {
                                    self.lineLimit = nil
                                } else {
                                    self.lineLimit = 3
                                }
                            }, label: {
                                Text("더보기")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                            })
                            .offset(y:20)
                        }
                    }
                }
                Spacer(minLength: 30)
                movieInformationView()
                
                Spacer()
        }
        .padding(.horizontal, PaddingConfig.sidePadding.value())
    }
    
    func movieInformationView() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items[..<items.count], id: \.self) { item in
                    Text(item)
                        .frame(width: 100, height: 50) // 예시 크기
                        .border(.black) // 예시 테두리
                }
            }
        }
    }
    
    func getLineValue(text: String, font: UIFont, width: CGFloat) -> Double {
        let constraint = CGSize(width: width, height: .greatestFiniteMagnitude)
        let totalHeight = text.boundingRect(with: constraint, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return Double(totalHeight.height/font.lineHeight)
    }

}



#Preview {
    posterItemDetailView(movieId: 100)
}
