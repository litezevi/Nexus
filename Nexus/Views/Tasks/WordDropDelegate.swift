import SwiftUI

struct WordDropDelegate: DropDelegate {
    @Binding var items: [String]
    let currentIndex: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { string, error in
            guard let string = string as? String,
                  let sourceIndex = Int(string) else { return }
            
            DispatchQueue.main.async {
                let item = items[sourceIndex]
                items.remove(at: sourceIndex)
                items.insert(item, at: currentIndex)
            }
        }
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}