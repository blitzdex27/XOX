//
//  ConfigView.swift
//  XOX
//
//  Created by Ss on 10/16/23.
//

import SwiftUI

struct ConfigView: View {
    
    @Binding private var xoxVM: XOXGameViewModel
    
    @Binding private var isPresented: Bool
    
    init(isPresented: Binding<Bool>, xoxVM: Binding<XOXGameViewModel>) {
        self._isPresented = isPresented
        self._xoxVM = xoxVM
        self._startingPiece = State(initialValue: xoxVM.currentConfig.startingPieceValueString.wrappedValue)
        self._columns = State(initialValue: xoxVM.currentConfig.columns.wrappedValue)
        self._rows = State(initialValue: xoxVM.currentConfig.rows.wrappedValue)
        self._pieceMatchCountToWin = State(initialValue: xoxVM.currentConfig.pieceMatchCountToWin.wrappedValue)
    }
    
    @State private var startingPiece: String
    private let pieces = ["X", "O"]
    
    @State private var columns: Int
    private let columnsOptions = [3, 4, 5]
    
    @State private var rows: Int
    private let rowsOptions = [3, 4, 5]
    
    @State private var pieceMatchCountToWin: Int
    private var pieceMatchCountToWinOptions: [Int] {
        Array(3...min(columns, rows))
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    Picker("", selection: $startingPiece) {
                        ForEach(pieces, id: \.self) { piece in
                            Text(piece)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Starting Piece")
                }
                
                Section {
                    Picker("Columns", selection: $columns) {
                        ForEach(columnsOptions, id: \.self) { columns in
                            Text("\(columns)")
                        }
               
                    }
                    Picker("Rows", selection: $rows) {
                        ForEach(rowsOptions, id: \.self) { rows in
                            Text("\(rows)")
                        }
                    }
                } header: {
                    Text("Size")
                }
                
                Section {
                    Picker("Piece Matched Count to Win", selection: $pieceMatchCountToWin) {
                        ForEach(pieceMatchCountToWinOptions, id: \.self) { count in
                            Text("\(count)")
                        }
                    }
                }
                
            }
            .navigationTitle("Config")
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                        
                        guard let startingPieceVariation = XOXPiece.Variation(rawValue: startingPiece) else {
                            return
                        }
//                        
                        xoxVM = .init(
                            startingPieceVariation: startingPieceVariation,
                            columns: columns,
                            rows: rows,
                            pieceMatchCountToWin: pieceMatchCountToWin)
                    }
                }
            })
        }
        
    }
}
//
//struct ConfigView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfigView()
//    }
//}
