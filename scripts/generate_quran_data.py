import json
import os
import requests
from collections import defaultdict

# Function to fetch Quran data from Tanzil API
def fetch_quran_data():
    # Using Tanzil's Quran text in Uthmani script
    url = "https://api.alquran.cloud/v1/quran/ar.alafasy"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    return None

def generate_quran_json():
    # Fetch Quran data
    quran_data = fetch_quran_data()
    if not quran_data:
        print("Failed to fetch Quran data")
        return

    # Initialize the output structure
    output = {
        "quran": {
            "metadata": {
                "totalSurahs": 114,
                "totalPages": 604,
                "totalJuz": 30,
                "version": "1.0",
                "source": "Mushaf Uthmani - Tanzil"
            },
            "surahs": [],
            "pages": []
        }
    }

    # Juz and page information (simplified - in a real scenario, you'd map each verse to its juz and page)
    # This is a placeholder - you would need to get the actual juz and page numbers
    juz_page_map = {}

    # Process surahs
    for surah in quran_data.get('data', {}).get('surahs', []):
        surah_number = surah['number']
        surah_name = surah['name']
        surah_english_name = surah['englishName']
        surah_english_name_translation = surah.get('englishNameTranslation', '')
        revelation_type = surah['revelationType']
        is_makki = revelation_type.lower() == 'meccan'
        
        verses = []
        for verse in surah.get('ayahs', []):
            verse_number = verse['numberInSurah']
            verse_text = verse['text']
            
            # Default values - in a real implementation, you'd get these from a proper mapping
            juz_number = (verse['number'] // 20) % 30 + 1  # Simplified juz calculation
            page_number = (verse['number'] // 10) % 600 + 1  # Simplified page calculation
            
            verses.append({
                "number": verse_number,
                "text": verse_text,
                "juzNumber": juz_number,
                "pageNumber": page_number
            })
        
        output["quran"]["surahs"].append({
            "number": surah_number,
            "name": surah_english_name_translation,
            "arabicName": surah_name,
            "numberOfVerses": len(verses),
            "revelationType": revelation_type,
            "isMakki": is_makki,
            "verses": verses
        })
    
    # Generate pages data (simplified)
    for page in range(1, 605):
        page_verses = []
        # In a real implementation, you would map verses to pages here
        
        output["quran"]["pages"].append({
            "pageNumber": page,
            "juzNumber": ((page - 1) // 20) + 1,  # Simplified juz calculation
            "verses": page_verses
        })
    
    # Save to file
    output_file = os.path.join('assets', 'complete_quran_data.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"Quran data generated successfully at {output_file}")

if __name__ == "__main__":
    generate_quran_json()
