////
//  Settings.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/1.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConfig.key_apiKey) var apiKey: String = ""

    @AppStorage(AppConfig.key_preserveCopyright) var preserveCopyright: Bool = false
    @AppStorage(AppConfig.key_preserveCreation) var preserveCreation: Bool = false
    @AppStorage(AppConfig.key_preserveLocation) var preserveLocation: Bool = false

    @AppStorage(AppConfig.key_concurrentTaskCount) var concurrentCount: Int = AppContext.shared.appConfig.concurrentTaskCount
    let concurrentCountOptions = Array(1 ... 6)

    @AppStorage(AppConfig.key_replaceMode) var replaceMode: Bool = false
    @State var outputFilepath: String = AppContext.shared.appConfig.outputFolderUrl?.rawPath() ?? ""

    @FocusState private var isTextFieldFocused: Bool

    @State private var failedToSelectOutputDirectory: Bool = false
    @State private var disableReplaceModeAfterSelect: Bool = false
    @State private var showSelectOutputFolder: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("TinyPNG")
                        .font(.system(size: 13, weight: .bold))

                    SettingsItem(title: "API key:", desc: "Visit [https://tinypng.com/developers](https://tinypng.com/developers) to request an API key.") {
                        TextField("", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = false
                            }
                    }

                    SettingsItem(title: "Preserve:", desc: nil) {
                        VStack(alignment: .leading) {
                            Toggle("Copyright", isOn: $preserveCopyright)
                            Toggle("Creation", isOn: $preserveCreation)
                            Toggle("Location", isOn: $preserveLocation)
                        }
                    }

                    Spacer()
                        .frame(height: 16)

                    Text("Tasks")
                        .font(.system(size: 13, weight: .bold))

                    SettingsItem(title: "Concurrent tasks:", desc: nil) {
                        Picker("", selection: $concurrentCount) {
                            ForEach(concurrentCountOptions, id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .padding(.leading, -8)
                        .frame(maxWidth: 80)
                    }

                    SettingsItem(title: "Overwrite Mode:", desc: "When \"Overwrite Mode\" is enabled, the compressed image will replace the original file. The original image is kept until the app exits and can be restored during this time.") {
                        Toggle(replaceMode ? "Enabled" : "Disabled", isOn: $replaceMode)
                    }

                    SettingsItem(title: "Output directory:", desc: "When \"Overwrite Mode\" is disabled, the compressed image will be saved to this directory. If a file with the same name exists, it will be overwritten.") {
                        HStack(alignment: .top) {
                            Text(outputFilepath.isEmpty ? "--" : outputFilepath)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                showOpenPanel()
                            } label: {
                                Text("Select...")
                            }

                            if AppContext.shared.isDebug {
                                Button {
                                    AppContext.shared.appConfig.clearOutputFolder()
                                } label: {
                                    Text("Clear")
                                }
                            }
                        }
                    }
                }.padding(24)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("settingViewBackground"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("settingViewBackgroundBorder"), lineWidth: 1)
                    }
            }
        }
        .padding(16)
        .onChange(of: replaceMode) { newValue in
            if !newValue && outputFilepath.isEmpty {
                replaceMode = true
                showSelectOutputFolder = true
                disableReplaceModeAfterSelect = true
            }
        }
        .onDisappear {
            AppContext.shared.appConfig.update()
        }
        .alert("Failed to save output directory",
               isPresented: $failedToSelectOutputDirectory
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a different directory.")
        }
        .alert("Select output directory", isPresented: $showSelectOutputFolder) {
            Button("OK") {
                DispatchQueue.main.async {
                    disableReplaceModeAfterSelect = false
                    showOpenPanel()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Disable \"Overwrite Mode\" after selecting the output directory.")
        }
    }

    private func showOpenPanel() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Select"

        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                print("User granted access to: \(url.rawPath())")

                do {
                    try AppContext.shared.appConfig.saveBookmark(for: url)
                    outputFilepath = url.rawPath()

                    if disableReplaceModeAfterSelect {
                        disableReplaceModeAfterSelect = false
                        replaceMode = false
                    }
                } catch {
                    failedToSelectOutputDirectory = true
                }
            } else {
                print("User did not grant access.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
