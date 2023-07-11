import SwiftUI
import AVFoundation

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var color: Color
    var isImportant: Bool
}

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var tasks: [Task] = []
    @State private var newTask: String = ""
    @State private var selectedColor: Color = .blue
    @State private var isEditing: Bool = false
    @State private var editingTaskIndex: Int?
    @State private var editingTask: Task = Task(title: "", color: .blue, isImportant: false)
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Toggle(isOn: $isDarkMode, label: {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                })
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            Text("Todo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            HStack {
                TextField("New Task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    addTask()
                }) {
                    Text("Add")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            List {
                ForEach(tasks) { task in
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .background(task.isImportant ? Color.red : task.color)
                        .cornerRadius(8)
                        .contextMenu {
                            Button(action: {
                                startEditing(task)
                            }) {
                                Label("Update", systemImage: "pencil")
                            }
                            Button(action: {
                                deleteTask(task)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .onTapGesture(count: 2) {
                            toggleTaskImportance(task)
                        }
                }
                .onMove(perform: moveTask)
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $isEditing) {
            editTaskView()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    
    private func addTask() {
        if(newTask == ""){
            return;
        }
        let task = Task(title: newTask, color: selectedColor, isImportant: false)
        tasks.append(task)
        newTask = ""
    }
    
    private func startEditing(_ task: Task) {
        editingTask = task
        editingTaskIndex = tasks.firstIndex(where: { $0.id == task.id })
        isEditing = true
    }
    
    private func updateTask() {
        guard let index = editingTaskIndex else { return }
        tasks[index] = editingTask
        isEditing = false
    }
    
    private func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    private func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
    
    private func toggleTaskImportance(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isImportant.toggle()
    }
    
    @ViewBuilder
    private func editTaskView() -> some View {
        VStack {
            TextField("Task", text: $editingTask.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            ColorPicker("Color", selection: $editingTask.color)
                .padding()
            
            Button(action: {
                updateTask()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
