13jan26: Who use the storage, which protocol
- **Content Curation Team (SMB/SMB/SFTP):** Edit in hot tier, store infrequently used files in warm tier, long-term storage in archive tier
- **ZTE VoD Platform (NFS all tiers):** Ingest original files, transcode, and process metadata across all 3 tiers
- **MediaProxy Recorder (NFS):** Record live sources to hot tier, auto-move to warm when inactive
- **Vantage Transcoder/Packager (NFS):** Read/write from hot tier, auto-move to warm when inactive
- **Cloud Transcoder (Aspera):** Read/write from hot tier, auto-move to warm when inactive
- **Content Editor (SMB/SMB/SFTP):** Adobe Premiere editing on hot tier for optimal performance
- **Content Partner (Aspera):** External users read/write to warm tier only
