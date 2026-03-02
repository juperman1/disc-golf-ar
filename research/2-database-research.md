# Disc Database Research

## Data Sources

### 1. Existing Databases

#### PDGA (Professional Disc Golf Association)
- **URL**: pdga.com
- **Data**: Approved discs list, specifications
- **API**: Limited public API
- **Coverage**: All PDGA-approved discs (3000+)
- **Access**: Scraping allowed? Unclear terms

#### Manufacturer Databases
- **Innova**: innovadiscs.com - Flight ratings, plastic types
- **Discraft**: discraft.com - Complete lineup with specs
- **Dynamic Discs**: dynamicdiscs.com - Full catalog
- **Latitude 64**: latitude64.se - European manufacturer
- **MVP Disc Sports**: mvpdiscsports.com - Overmold specialists
- **Prodigy**: prodigydisc.com - Direct flight numbers
- **Axiom/MVP**: axiomdiscs.com - Gyro technology

#### Community Databases
- **InfiniteDiscs.com**: 
  - 2000+ discs with flight ratings
  - User reviews and ratings
  - Searchable database
  - **No public API**, but scrapeable?
  - Most comprehensive resource

- **MarshallStreetDiscGolf.com**:
  - Flight chart comparison tool
  - Excellent visual interface
  - Filter by flight numbers

- **DiscGolfCourseReview.com**:
  - Disc reviews and flight paths
  - Community data

### 2. Data Structure Needed

```json
{
  "disc": {
    "id": "unique-identifier",
    "name": "Destroyer",
    "manufacturer": "Innova",
    "type": "distance-driver",
    "flight_numbers": {
      "speed": 12,
      "glide": 5,
      "turn": -1,
      "fade": 3
    },
    "plastics": ["Star", "Champion", "Pro"],
    "weight_range": "150-175g",
    "dimensions": {
      "diameter": "21.1cm",
      "height": "1.4cm",
      "rim_depth": "1.1cm",
      "rim_width": "2.2cm"
    },
    "images": {
      "top_view": "url",
      "side_view": "url",
      "profile": "url"
    },
    "description": "Overstable distance driver..."
  }
}
```

### 3. Data Acquisition Strategy

#### Option A: Manual Curation (MVP)
- Start with top 100-200 most popular discs
- Manually enter from manufacturer websites
- Create seed database
- **Time investment**: ~10-20 hours
- **Pros**: Legal, controlled, high quality
- **Cons**: Limited scope initially

#### Option B: Web Scraping (Advanced)
- Scrape InfiniteDiscs, manufacturer sites
- Automated collection
- **Legal risk**: Terms of Service violations
- **Technical**: Requires maintenance
- **Scope**: 2000+ discs possible

#### Option C: Community Sourcing (Long-term)
- Allow users to submit disc data
- Review and approve submissions
- Crowdsource database growth
- **Pros**: Scalable, community engagement
- **Cons**: Requires moderation system

#### Option D: API Partnership (Future)
- Contact manufacturers for API access
- InfiniteDiscs partnership
- Official data feed
- **Pros**: Legal, accurate, maintained
- **Cons**: Requires business relationships

## Recommended Approach for MVP

### Phase 1: Core Discs (MVP)
- **100 most popular discs**
- Cover major manufacturers
- Focus on driver/midrange/putter mix
- Manual data entry from manufacturer specs

### Phase 2: Collection Expansion
- Add 100 more popular discs
- User requests prioritized
- Manufacturer coverage expansion

### Phase 3: Comprehensive (Future)
- Web scraping or API integration
- 2000+ discs
- Community contributions

## Top Discs to Include (MVP)

### Distance Drivers
1. Innova Destroyer
2. Innova Boss
3. Innova Shryke
4. Innova Wraith
5. Discraft Force
6. Discraft Zeus
7. Dynamic Discs Sheriff
8. Dynamic Discs Trespass
9. Latitude 64 Ballista
10. MVP Octane

### Fairway Drivers
1. Innova TeeBird
2. Innova Leopard
3. Discraft Buzzz (OS)
4. Dynamic Discs Escape
5. Latitude 64 Saint
6. MVP Signal
7. Axiom Crave

### Midranges
1. Innova Roc3
2. Innova Mako3
3. Discraft Buzzz
4. Discraft Comet
5. Dynamic Discs EMac Truth
6. Dynamic Discs Verdict
7. Latitude 64 Core

### Putters
1. Innova Aviar
2. Innova Nova
3. Discraft Magnet
4. Discraft Challenger
5. Dynamic Discs Judge
6. Dynamic Discs Warden
7. Latitude 64 Pure

## Estimated MVP Scope
- **100 discs total**
- **~10 manufacturers**
- **All major plastic types**
- **Complete flight numbers**
- **Basic descriptions**

## Next Steps
1. Create data structure JSON schema
2. Manually enter 100 popular discs
3. Set up local SQLite database
4. Create search/filter functionality
5. Plan for expansion strategy
