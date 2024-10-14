package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
)

func main() {
	http.HandleFunc("/", greet)
	fmt.Println("Sunucu 8080 portunda başlatılıyor...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func greet(w http.ResponseWriter, r *http.Request) {
	// CORS başlıklarını ayarla
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	// URL'den ismi al
	name := strings.TrimPrefix(r.URL.Path, "/")
	if name == "" {
		name = "Misafir"
	}

	// Yanıtı oluştur
	response := map[string]string{
		"message": fmt.Sprintf("Merhaba, %s! Academy 2024 BCFM 1.Sprint'e hoş geldin!", name),
	}

	// JSON olarak yanıt ver
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
