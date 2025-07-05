//
//  ShoppingListGroceryListView.swift
//  Meshipe
//
//  Created by Rachel  Tan on 4/14/25.
//
import SwiftUI
import SwiftData

struct ShowGroceryListView: View {
    @Binding var groceryList: [GroceryItem]
    @State var isEditing: Bool = false
    @State var mode: EditMode = .inactive
    @State private var newGrocery: String = ""
    @State var completed: Set<UUID> = []

    var body: some View{
        VStack {
            List {
                ForEach($groceryList.indices, id: \.self) { index in
                    if mode == .inactive {
                        HStack {
                            Image(systemName: completed.contains(groceryList[index].id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(completed.contains(groceryList[index].id) ? .yellow : .gray)
                                .onTapGesture {
                                    toggleCompletion(for: groceryList[index].id)
                                }
                            Text(groceryList[index].item)
                                .strikethrough(completed.contains(groceryList[index].id), color: .gray) // Strike-through when selected
                                .onTapGesture {
                                    toggleCompletion(for: groceryList[index].id)
                                }
                        }
                    } else {
                        TextField("Enter item", text: $groceryList[index].item)
                    }
                }
                .onDelete(perform: deleteItem)

                if mode == .active {
                    Button(action: addItem) {
                        Label("Add Items", systemImage: "plus.circle.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)

            Spacer()
            
            Button(action: {
                groceryList.removeAll()
            }) {
                Text("Clear Grocery List")
                    .padding()
                    .cornerRadius(8)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 20)
            .buttonStyle(BrownButton())

        }
        .background(Color.lighterPastelYellow)
        .foregroundColor(Color.darkBrown)
        .navigationTitle("Grocery List")
        .toolbar {
            EditButton()
                .buttonStyle(BrownButton())
                .padding(.trailing)
        }
        .environment(\.editMode, $mode)
        
    }
    private func toggleCompletion(for itemID: UUID) {
        if completed.contains(itemID) {
            completed.remove(itemID)  // Unmark as completed
        } else {
            completed.insert(itemID)  // Mark as completed
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        groceryList.remove(atOffsets: offsets)
        for index in offsets {
            let itemID = groceryList[index].id
            completed.remove(itemID)
        }
    }
    
    private func addItem() {
        groceryList.append(GroceryItem(item: ""))
    }
}



#Preview {
    @Previewable @State var testrecipes = [Recipe(title: "title2",url: "test2", ingredients: ["i1","i2","i3"], instructions: ["test2"]), Recipe(title: "title3", url: "test3",ingredients: ["i1","i2","i3"], instructions: ["test3"])]
    @Previewable @State var testList = [GroceryItem(item:"1 chocolate"), GroceryItem(item:"2 Tofu")]
    @Previewable @State var selectedTab = 0
    @Previewable @State var navPath = NavigationPath()
    ShowGroceryListView(groceryList: $testList)
        .modelContainer(.preview)
}
