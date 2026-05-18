# Credshunter
Automated web asset discovery &amp; sensitive data hunter using Katana
Tool ini digunakan untuk:

✅ Crawl website (deep + JS + headless + XHR)
✅ Extract endpoint & API
✅ Detect parameter (IDOR, SSRF, dll)
✅ Download HTML & JS
✅ Hunt sensitive data (API key, token, JWT)
✅ Generate request list for testing (Burp / ffuf)


⚡ Features

🔥 Katana full mode (-jc -jsl -kf -hl -xhr)
🔥 Endpoint discovery (JS + XHR + regex)
🔥 Parameter mining (?id=, ?token=)
🔥 Sensitive data extraction (API Key / JWT / Bearer)
🔥 Clean filename (no hash)
🔥 Exclude domain support (-e exclude.txt)
🔥 High-value endpoint filtering
🔥 Request list generator (ready for fuzzing)


📦 Installation
Shellgit clone https://github.com/you/credshunter-elitecd credshunter-elitechmod +x credshunter_elite.shShow more lines
Requirement

katana
jq
curl
chromium (untuk headless)


▶️ Usage
Basic
Shell./credshunter_elite.sh -i targets.txtShow more lines
With exclude list
Shell./credshunter_elite.sh -i targets.txt -e exclude.txt``Show more lines
Custom threads
Shell./credshunter_elite.sh -i targets.txt -t 5Show more lines

📂 Output Structure
output/
 ├── domain.jsonl
 ├── domain-urls.txt
 ├── domain-params.txt
 ├── domain-fuzz.txt
 ├── domain-endpoints.txt
 ├── domain-highvalue.txt
 ├── domain-secrets.txt
 ├── domain-requests.txt
 ├── domain/
 │    ├── *.html
 │    ├── *.js


🔍 Example Output
URLs
https://target.com/api/user?id=1

Params
/api/user?id=1

Fuzz
/api/user?FUZZ=1

Secrets
app.js:api_key=AIzaSyXXXX
login.js:Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9

High-value endpoint
/admin
/api/login
/debug


⚙️ Exclude Mode (-e)
Isi file exclude.txt:
cdn.datatables.net
cdn.jsdelivr.net
googleapis.com

👉 Semua URL yang match akan di-skip dari:

✅ crawling result
✅ endpoint parsing
✅ download


🧠 Workflow
[1] Input Target
      ↓
[2] Katana Crawling
      ↓
[3] Extract URL + XHR
      ↓
[4] Filter (exclude, deduplicate)
      ↓
[5] Download JS & HTML
      ↓
[6] Endpoint Extraction (regex + JS)
      ↓
[7] Parameter Mining
      ↓
[8] Sensitive Data Detection
      ↓
[9] Generate Request List


🎯 Use Case

Bug bounty recon 🔥
API discovery
IDOR / SSRF hunting
Credential leakage detection
Attack surface mapping


⚠️ Notes

Tidak semua target punya banyak endpoint (tergantung complexity)
SPA / modern app → hasil lebih banyak
Static site → hasil lebih sedikit (normal)


🛠 Tips

Gunakan -e exclude.txt untuk reduce noise
Fokus ke:
domain-highvalue.txt
domain-secrets.txt


Gunakan domain-fuzz.txt untuk ffuf:
Shellffuf -u https://target.com/FUZZ -w wordlist.txtShow more lines



🧠 Pro Tips


Endpoint dengan kata:
admin, auth, login, create, update

👉 high chance vulnerable


Parameter seperti:
id=, user=, token=

👉 kandidat IDOR / injection



📌 TODO (Future Improvement)

 Secret validator (live check)
 Auto nuclei integration
 Endpoint risk scoring
 Auto exploit preparation


⚖️ Disclaimer
Tool ini hanya untuk:

✅ Pentest authorized
✅ Bug bounty program

JANGAN digunakan untuk aktivitas ilegal.
