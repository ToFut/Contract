import SwiftUI
import PDFKit

struct ContentView: View {
    @State private var fileURL: URL?
    @State private var isAnalyzing: Bool = false
    @State private var showAlert: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var analysisResults: AnalysisResults?
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                if isAnalyzing {
                    ZStack {
                        Color(.white)
                            .opacity(0.8)
                            .ignoresSafeArea()

                        VStack {
                            ProgressView("Analyzing Contract...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .font(.title2)
                                .padding()
                            Text("Please wait while we analyze your contract.")
                                .font(.subheadline)
                                .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding()
                    }
                } else {
                    VStack {
                        VStack(alignment: .leading) {
                            Button(action: {
                                isFileImporterPresented = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                    Text("Select PDF File")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .padding(.bottom, 20)

                            if let fileURL = fileURL {
                                Text("Selected File: \(fileURL.lastPathComponent)")
                                    .padding()
                                    .font(.headline)
                            }
                        }
                        .padding()

                        Button("Analyze PDF") {
                            if let fileURL = fileURL {
                                analyzeContract(fileURL: fileURL) { result in
                                    switch result {
                                    case .success(let analysis):
                                        analysisResults = analysis
                                    case .failure(let error):
                                        errorMessage = error.localizedDescription
                                        showAlert = true
                                    }
                                }
                            } else {
                                errorMessage = "Please select a file first."
                                showAlert = true
                            }
                        }
                        .padding()
                        .disabled(fileURL == nil || isAnalyzing)
                        .buttonStyle(BorderedButtonStyle())
                        
                        // NavigationLink updated for iOS 16+
                        if let analysisResults = analysisResults {
                            NavigationLink(destination: ResultsView(results: analysisResults)) {
                                Text("View Results")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .disabled(fileURL == nil || isAnalyzing)
                        }
                    }
                    .navigationTitle("Contract Analyzer")
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [.pdf]
                    ) { result in
                        do {
                            let url = try result.get()
                            fileURL = url
                        } catch {
                            print("Failed to import file: \(error.localizedDescription)")
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }

    func analyzeContract(fileURL: URL, completion: @escaping (Result<AnalysisResults, Error>) -> Void) {
        guard !isAnalyzing else { return }
        isAnalyzing = true

        extractText(from: fileURL) { text in
            guard let text = text else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to extract text from PDF."
                    showAlert = true
                    isAnalyzing = false
                }
                return
            }

            sendToServer(fileURL: fileURL) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let analysis):
                        completion(.success(analysis))
                    case .failure(let error):
                        errorMessage = "Server error: \(error.localizedDescription)"
                        showAlert = true
                    }
                    isAnalyzing = false
                }
            }
        }
    }

    func extractText(from url: URL, completion: @escaping (String?) -> Void) {
        guard let pdfDocument = PDFDocument(url: url) else {
            completion(nil)
            return
        }

        let pdfText = pdfDocument.string
        completion(pdfText)
    }

    func sendToServer(fileURL: URL, completion: @escaping (Result<AnalysisResults, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/upload") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "--\(boundary)--\r\n"

        var body = Data()

        let fileData = try? Data(contentsOf: fileURL)
        let fileName = fileURL.lastPathComponent

        if let fileData = fileData {
            body.append("\(boundaryPrefix)".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("\(boundarySuffix)".data(using: .utf8)!)

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Server returned an error or non-200 status code")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server error or non-200 status code"])))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let analysisResults = try decoder.decode(AnalysisResults.self, from: data)
                completion(.success(analysisResults))
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
