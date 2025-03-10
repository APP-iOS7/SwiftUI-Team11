/*
 Version : 1_0_1
 Date    : 2025-03-08(SAT)
 Log     : Poster Detail View Draft and Hero Section didn't show image bugfix
 */

import SwiftUI
import UIKit


struct posterItemDetailView: View {
    @State private var isBookmarked : Bool = false
    @State private var movieInfo : SearchResults?
    @State private var onSheet : Bool = false
    
    @State private var title : String = ""
    @State private var releaseDate : String = ""
    @State private var genre : String = ""
    @State private var posterPath : String = ""
    @State private var rate : Double = 0
    @State private var comment : String = ""
    
    @State private var overview : String = ""
    @State private var backdropPath : String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    
    
    
    var heroSectionHeight : CGFloat
    var moiveId : Int
    
    init(movieId: Int, _ heroSectionHeight: CGFloat = 230) {
        self.heroSectionHeight = heroSectionHeight
        self.moiveId = movieId
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                HeroSection(frameHeight: heroSectionHeight,title: $title, releaseDate: $releaseDate, genre: $genre, posterPath: $posterPath, backdropPath: $backdropPath)
                Spacer(minLength: 40)
                ratingView(movieId: moiveId,rating: $rate)
                    .frame(height: 50)
                Spacer(minLength: 30)
                buttonView
                Spacer(minLength: 34)
                Divider()
                CommtentView
                Divider()
                Spacer(minLength: 11)
                detailView(overview: $overview)
                Spacer()
            }
        }
        .onAppear() {
            getMovieInfoForId()
        }
        .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("뒤로")
                            }
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                        }
                    }
                }
    }
    
    func getMovieInfoForId() {
        Task {
            movieInfo = await serchIDRequest(id: moiveId)
            title = movieInfo?.movieDetails[0].title ?? ""
            if let releaseDate = movieInfo?.movieDetails[0].releaseDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                let formattedYear = dateFormatter.string(from: releaseDate)
                self.releaseDate = formattedYear
            }
            
            genre = movieInfo?.movieDetails[0].genreIds.joined(separator: ", ") ?? ""
            comment = movieInfo?.movieDetails[0].comment ?? ""
            posterPath = movieInfo?.movieDetails[0].posterPath ?? ""
            rate = Double(movieInfo?.movieDetails[0].rate ?? 0.0)
            isBookmarked = movieInfo?.movieDetails[0].isBookmarked ?? false
            overview = movieInfo?.itemDetails[0].overview ?? ""
            backdropPath = movieInfo?.itemDetails[0].backdropPath ?? ""
        }
    }
    
    var CommtentView : some View {
        VStack {
            HStack() {
                Text("코멘트")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal)
                Spacer()
            }
            Text(comment)
        }
    }
    
    var buttonView : some View {
        HStack(spacing: 47) {
            Button(
                action: {
                    Task {
                        await bookmarkedButtonClicked()
                    }
                },
                label: {
                    HStack{
                        Image(systemName: isBookmarked ? "suit.heart.fill" : "plus")
                        Text("보고 싶어요!")
                            .font(.system(size: 18, weight: .bold))
                    }
            })
            .frame(width: 140, height: 50)
            .background(isBookmarked ? ColorConfig.primaryColor.value() : ColorConfig.commonGrey.value())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.black)
            Button(
                action: {
                    onSheet.toggle()
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
        .sheet(isPresented: $onSheet ) {
            createCommentView(moiveId: moiveId, comment: $comment)
        }
    }
    
    func bookmarkedButtonClicked() async {
        isBookmarked.toggle()
        print(moiveId)
        await updateRequest(model: "item_movie", id: moiveId, isBookmarked: isBookmarked)
    }
}

struct HeroSection: View {
    //init value
    var frameHeight : CGFloat
    @Binding var title : String
    @Binding var releaseDate : String
    @Binding var genre : String
    @Binding var posterPath : String
    @Binding var backdropPath : String
    
    
    @State private var imageWidth: CGFloat = 0
    @State private var initMinY : CGFloat = 0
    
    //state value
    @State private var imageOpacity : Double = 1

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .global).minY
                let midX = proxy.frame(in: .global).midX
                
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500/\(backdropPath)")) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .scaledToFill()
                    .frame(width: imageWidth, height: frameHeight + (minY > 0 ? minY : 0), alignment: .bottom)
                    .offset(x: -midX + imageWidth / 2, y: minY > 0 ? -minY : 0)
                    .opacity(imageOpacity)
                    .brightness(-0.2)
                    .colorMultiply(.gray)
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
                        print("\(backdropPath) \(posterPath)")
                    }
            }
            VStack {
                Spacer()
                HStack(spacing: PaddingConfig.heroSectionHorizonSpacing.value()) {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500/\(posterPath)")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFit()
                        .frame(width: 70, height: 105)
                    VStack(alignment: .leading ,spacing: PaddingConfig.heroSectionVerticalSpacing.value()) {
                        Text("\(title)")
                            .font(.system(size: PaddingConfig.heroSectionTitle.value(), weight: .bold))
                            .foregroundStyle(ColorConfig.heroSectionTitle.value())
                        Text("\(releaseDate)/\(genre)")
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
    var movieId: Int
    @Binding var rating: Double
    @State private var starView: makeStarView?
    @State private var isDoubleTapped: Bool = false
    
    
    var body: some View {
        if let starView = starView {
            starView
                .onAppear {
                    self.starView = makeStarView(movieId: movieId,rating : $rating, isDoubleTapped: $isDoubleTapped)
                }
        }
        else {
            makeStarView(movieId: movieId ,rating: $rating, isDoubleTapped: $isDoubleTapped)
        }
    }
}

struct makeStarView: View {
    var movieId: Int
    @Binding var rating: Double
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
                        starView(systemName: "star.fill.left", index : currentIterationCount)
                            .foregroundStyle(.black)
                    }
                    else {
                        starView(systemName: "star", index : currentIterationCount)
                            .foregroundStyle(.black)
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
                    .onEnded() {_ in
                        Task {
                            await updateRequest(model: "item_movie", id: movieId, rate: Float(rating))
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
        Task {
            await updateRequest(model: "item_movie", id: movieId, rate: Float(rating))
        }
    }
}

//정보 표시 수정 필요
struct detailView: View {
    @Binding var overview: String
    
    @State private var lineLimit: Int? = 3
    @State private var isLineLimitUpper : Bool = false
    @State private var textWidth : CGFloat = 0
    
    let items = ["감독", "상영 시간", "연령 등급", "장르", "제작 국가", "제작 연도", "기타1", "기타2"]
    let maxVisibleItems : Int = 4
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    Text("개요")
                        .font(.system(size: 16, weight: .bold))
                        .onChange(of: overview) {
                            self.textWidth = geometry.frame(in: .local).width
                            let lineValue : Double = getLineValue(text: overview, font: UIFont.systemFont(ofSize: 15), width: textWidth)
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
                        Text(overview)
                            .font(.system(size: 15))
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
    posterItemDetailView(movieId: 11)
}
