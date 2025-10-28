# Automated Lost-Item Retrieval System

A multimodal search application that helps users find lost items using AI-powered image and text matching. Built with OpenAI's CLIP (Contrastive Language-Image Pre-training) model for semantic similarity search.

## Overview

This system allows staff to report found items and users to search for their lost belongings using either text descriptions or images. The application uses CLIP-ViT-B/32 to generate embeddings and performs cosine similarity matching to find the best matches.

## Features

- **Multimodal Search**: Search using text descriptions or images
- **Real-time Image Capture**: Report items using webcam or upload images
- **Embedding-based Matching**: Uses CLIP model for semantic similarity
- **Staff Portal**: Secure authentication for resolving cases
- **Location Management**: Campus and building-specific item tracking
- **Contact Information**: Automatic email lookup for item pickup locations

## Demo

Check out the video demo included in this repository to see the application in action!

https://github.com/user-attachments/assets/bc9c4696-0dea-48dd-8a96-27b23905a51f

## Architecture

```
┌─────────────────┐
│   Streamlit UI  │
└────────┬────────┘
         │
    ┌────▼────┐
    │  CLIP   │
    │ ViT-B/32│
    └────┬────┘
         │
    ┌────▼────────┐
    │  Embeddings │
    │   (CSV)     │
    └─────────────┘
```

## Project Structure

```
lost-and-found-ai/
├── data/
│   ├── lost_items.csv          # Active lost items database
│   ├── resolved_items.csv      # Resolved cases archive
│   ├── users.csv              # Staff authentication
│   └── locations.xlsx         # Campus locations & contacts
├── lost_items/                # Uploaded item images
├── lostnfound.py             # Main application
├── requirements.txt          # Python dependencies
└── README.md
```

## Getting Started

### Prerequisites

- Python 3.8+
- pip

### Installation

1. Clone the repository:
```bash
git clone https://github.com/trishthakur/lost-and-found-ai
cd lost-and-found-ai
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up data files:
   - Create a `locations.xlsx` file with columns: `Campus`, `Building`, `Contact Email`
   - The application will automatically create CSV files on first run

### Running Locally

```bash
streamlit run lostnfound.py --server.port 7000
```

Access the application at `http://localhost:7000`

## Technical Details

### Model

- **CLIP Model**: `openai/clip-vit-base-patch32`
- **Embedding Dimension**: 512
- **Similarity Metric**: Cosine similarity
- **Matching Threshold**: 0.1

### Current Storage

This local deployment uses:
- **CSV files** for embedding storage
- **Local filesystem** for images
- **In-memory processing** for searches

### Scaling for Production

For production deployment with higher traffic, consider:

#### 1. **FAISS Integration** (Vector Database)

Replace CSV-based embedding storage with FAISS for faster similarity search:

```python
import faiss
import numpy as np

# Create FAISS index
dimension = 512  # CLIP embedding size
index = faiss.IndexFlatIP(dimension)  # Inner Product = Cosine for normalized vectors

# Add embeddings
embeddings = np.array([...])  # Your embeddings
faiss.normalize_L2(embeddings)  # Normalize for cosine similarity
index.add(embeddings)

# Search
query_embedding = np.array([...])
faiss.normalize_L2(query_embedding)
distances, indices = index.search(query_embedding, k=5)  # Top 5 matches
```

**Benefits:**
- Sub-millisecond search times for 1M+ vectors
- 10-100x faster than CSV iteration
- GPU acceleration support

#### 2. **Google Cloud Platform Deployment**

Deploy on GCP for scalability:

```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT_ID/lost-and-found

# Deploy to Cloud Run
gcloud run deploy lost-and-found \
  --image gcr.io/PROJECT_ID/lost-and-found \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2
```

**Recommended GCP Services:**
- **Cloud Run**: Serverless container deployment
- **Cloud Storage**: Image storage
- **Cloud SQL** or **Firestore**: Metadata storage
- **Cloud CDN**: Fast image delivery
- **Vertex AI**: Model hosting (optional)

**Architecture for Production:**
```
┌──────────────┐
│   Cloud Run  │
│  (Streamlit) │
└──────┬───────┘
       │
   ┌───▼────────┐
   │   FAISS    │
   │  (in-memory│
   │  or Cloud  │
   │  Storage)  │
   └───┬────────┘
       │
   ┌───▼──────────┐
   │ Cloud Storage│
   │   (images)   │
   └──────────────┘
```

## Authentication

Staff login is required for resolving cases. Default credentials should be set in `users.csv`:

```csv
Username,Password,Is_Admin
admin,<sha256_hash>,True
```

Passwords are stored as SHA-256 hashes.

## Data Management

### CSV Schema

**lost_items.csv / resolved_items.csv:**
- `Image Name`: Unique filename
- `Location`: Campus - Building
- `Timestamp`: Report datetime
- `Embedding`: CLIP embedding (serialized)
- `Description`: Optional text description
- `Status`: Lost/Found
- `Owner Details`: Claimant information

## Customization

### Adding New Campuses/Buildings

Edit `locations.xlsx` with:
- Campus name
- Building name
- Contact email for pickup

### Adjusting Similarity Threshold

In `lostnfound.py`, modify the threshold:
```python
if best_match and score >= 0.1:  # Adjust this value
```

Lower values = more results (less strict)
Higher values = fewer results (more strict)


## Contact

For questions or support, please open an issue on GitHub.

---

**Note:** This is a prototype developed for educational purposes. For production use, implement proper security measures, data encryption, and compliance with privacy regulations.

