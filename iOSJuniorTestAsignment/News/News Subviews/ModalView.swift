import SwiftUI

struct ModalView: View {
    
    @Environment(\.dismiss) var dismiss
    let block: NavigationBlock
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                if let symbol = block.title_symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 40))
                        .foregroundColor(.blueCustom)
                }
                
                Text(block.title ?? "")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.blackCustom)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
}
