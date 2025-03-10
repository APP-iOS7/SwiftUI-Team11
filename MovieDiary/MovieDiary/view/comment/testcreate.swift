import SwiftUI

struct CreateCommentView: View {
    @State private var caption = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("작품에 대한 생각을 자유롭게 적어주세요.", text: $caption, axis: .vertical)
                        .font(.system(size: 16))
                        .padding()
                    
                    Spacer()
                    if !caption.isEmpty {
                        Button {
                            caption = ""
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("코멘트 작성")
                        .font(.system(size: 24, weight: .bold))
                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("작성") {
                        
                    }
                    .opacity(caption.isEmpty ? 0.5 : 1.0)
                    .disabled(caption.isEmpty)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CreateCommentView()
}
