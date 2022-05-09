//
//  Home.swift
//  MapRoutes
//
//  Created by Вячеслав Квашнин on 13.08.2021.
//

import SwiftUI
import CoreLocation

struct Home: View {
    
    @StateObject var mapData = MapViewModel()
    
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            
            ZStack {
                Button(action: {
                    mapData.alertView { (text) in
                        mapData.mark(addressPlace: text)
                    }
                }, label: {
                    Text("Адрес")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
                
                if mapData.showButton == true {
                    
                    Button(action: {
                        
                        mapData.routeButton()
                        
                    }, label: {
                        Text("Маршрут")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                    
                    
                    Button(action: {
                        mapData.deletePin()
                    }, label: {
                        Text("Очистить")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding()
                }
            }
        }
        .onAppear(perform: {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        })
        .overlay(
            ForEach(mapData.massiv, id: \.self) { item in
                Text(item)
            }
        )
    }
}
