//
//  SupabaseClient.swift
//  mindfulness
//
//  Created by leo on 31/8/2568 BE.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Supabase configuration
        let url = URL(string: "https://myypqsxmhamgnjjvczgk.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15eXBxc3htaGFtZ25qanZjemdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY2NTgwMDEsImV4cCI6MjA3MjIzNDAwMX0.jq6pRddnnFuTHBF4dl_FVKfrTWqE0PG-O3veFa75_H8"
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    schema: "public"
                ),
                auth: SupabaseClientOptions.AuthOptions(
                    autoRefreshToken: true
                ),
                global: SupabaseClientOptions.GlobalOptions(
                    headers: [:]
                )
            )
        )
    }
}