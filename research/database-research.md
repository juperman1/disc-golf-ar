# Disc Golf Database Research

## Overview
To build a comprehensive AR disc golf app, you need reliable data sources for disc specifications, flight characteristics, and course information. This document covers available databases and APIs.

## Official Data Sources

### PDGA (Professional Disc Golf Association)
- **Website**: https://www.pdga.com/
- **API**: Limited public API available
- **Data Available**: 
  - Player ratings and statistics
  - Tournament results
  - Course directory (PDGA Course Directory)
  - Approved discs list
- **Pricing**: Free for basic information
- **Limitations**: No comprehensive disc database API; mostly focused on player/tournament data
- **Course Directory**: Can be scraped or accessed via limited API endpoints

### PDGA Technical Standards
- **Approved Discs List**: https://www.pdga.com/technical-standards/disc-specifications
- **Format**: HTML tables, some PDF documentation
- **Data Fields**: Disc name, manufacturer, diameter, height, rim depth, rim width, max weight
- **Updates**: Quarterly updates

## Manufacturer Databases

### Innova Discs
- **Website**: https://www.innovadiscs.com/
- **Product API**: None officially documented
- **Data Available**: Individual disc pages with flight ratings
- **Scraping**: Possible but not officially permitted

### Discraft
- **Website**: https://www.discraft.com/
- **API**: None public
- **Data**: Product catalog with flight numbers

### Dynamic Discs / Latitude 64 / Westside
- **Websites**: 
  - https://www.dynamicdiscs.com/
  - https://latitude64.se/
  - https://westsidediscs.com/
- **Shared Database**: These three manufacturers share production and data
- **Flight Chart**: https://www.dynamicdiscs.com/pages/flight-chart

### MVP Disc Sports / Axiom / Streamline
- **Website**: https://mvpdiscsports.com/
- **Data**: Detailed flight charts available

## Open/Community Databases

### Marshall Street Disc Golf Flight Guide
- **URL**: https://www.marshallstreetdiscgolf.com/flight-guide/
- **Features**: Interactive flight path visualizations
- **Data**: Extensive database with flight numbers
- **API**: None public, but data is accessible
- **Scraping**: HTML tables with disc data

### Disc Golf Review (DGR)
- **URL**: https://www.discgolfreview.com/
- **Database**: User-submitted reviews and ratings
- **API**: None
- **Community**: Active forums with expert knowledge

### Disc Golf Course Review
- **URL**: https://www.dgcoursereview.com/
- **Data**: Comprehensive course database with user reviews
- **API**: Limited read-only API available
- **Request Access**: Contact site administrators
- **Data Fields**: Course name, location, hole count, difficulty, ratings

### OpenDiscGolf (Open Source Project)
- **GitHub**: Search for community-maintained databases
- **Data Format**: Usually JSON or CSV
- **License**: Varies by project

## Crowd-Sourced Data Options

### Building Your Own Database

#### Schema Design
```json
{
  "disc": {
    "id": "uuid",
    "name": "string",
    "manufacturer": "string",
    "category": "putter|midrange|fairway_driver|distance_driver",
    "flight_numbers": {
      "speed": "integer (1-14)",
      "glide": "integer (1-7)",
      "turn": "integer (-5 to 1)",
      "fade": "integer (0-5)"
    },
    "dimensions": {
      "diameter": "float (cm)",
      "height": "float (cm)",
      "rim_depth": "float (cm)",
      "rim_width": "float (cm)",
      "max_weight": "float (g)"
    },
    "pdga_approved": "boolean",
    "pdga_number": "string",
    "stability": "understable|stable|overstable",
    "skill_level": "beginner|intermediate|advanced",
    "plastic_types": ["string"],
    "images": ["url"]
  }
}
```

### Course Data Schema
```json
{
  "course": {
    "id": "uuid",
    "name": "string",
    "location": {
      "latitude": "float",
      "longitude": "float",
      "address": "string",
      "city": "string",
      "state": "string",
      "country": "string"
    },
    "holes": [
      {
        "number": "integer",
        "par": "integer",
        "distance": "float (meters)",
        "tee_type": "concrete|grass|gravel|other",
        "basket_type": "permanent|portable",
        "difficulty": "integer (1-5)",
        "description": "string",
        "obstacles": ["tree|water|road|other"]
      }
    ],
    "difficulty_rating": "float",
    "course_rating": "float",
    "total_length": "float (meters)",
    "amenities": ["restrooms|water|pro_shop|other"]
  }
}
```

## Free Geospatial Data Sources

### OpenStreetMap (OSM)
- **URL**: https://www.openstreetmap.org/
- **Tag**: `sport=disc_golf`
- **Data**: Course locations, hole positions
- **Access**: Overpass API, Geofabrik downloads
- **License**: ODbL (Open Database License)
- **Query Example**:
```
[out:json];
area[name="Your City"]→.searchArea;
(
  node["sport"="disc_golf"](area.searchArea);
  way["sport"="disc_golf"](area.searchArea);
);
out body;
```

### Google Maps Platform
- **URL**: https://developers.google.com/maps
- **Pricing**: Free tier available ($200 credit/month)
- **Features**: 
  - Places API for course discovery
  - Geocoding for addresses
  - Elevation API for terrain
- **Usage**: Great for course search and mapping

### Mapbox
- **URL**: https://www.mapbox.com/
- **Free Tier**: 50,000 loads/month
- **Features**: Custom map styling for disc golf courses
- **Advantage**: More flexible than Google Maps for custom styling

## Recommended MVP Data Strategy

### Phase 1: Seed Database
1. **Manual Data Entry**: Start with top 50-100 most popular discs
2. **Sources**: 
   - Innova's website for flight numbers
   - PDGA approved list for specs
   - Marshall Street for comprehensive comparison
3. **Format**: SQLite or JSON for local storage
4. **Images**: Link to manufacturer websites (with credit)

### Phase 2: Course Data
1. **Use DGCourseReview API** (if approved) or
2. **OpenStreetMap Overpass API** for course locations
3. **Manual hole-by-hole** data for AR features (distances, obstacles)
4. **User submission** feature for community data expansion

### Phase 3: Cloud Integration
1. **Firebase Firestore**: Easy to set up, real-time sync
2. **Supabase**: PostgreSQL-based, generous free tier
3. **MongoDB Atlas**: Free tier, good for JSON document structure

## Community Resources

### Reddit r/discgolf
- **URL**: https://www.reddit.com/r/discgolf/
- **Community**: Active, helpful for feedback and beta testing
- **Data**: Users often share spreadsheets with disc databases

### Disc Golf Course Designer
- **UDisc**: https://udisc.com/ (proprietary, but industry standard)
- **Disc Golf Metrix**: https://discgolfmetrix.com/ (European focus, some open data)

### GitHub Repositories
Search for:
- "disc golf database"
- "discgolf json"
- "pdga api"
- "disc golf api"

Example repositories:
- `discgolfdb` community projects
- `flight-path` visualization tools

## Legal Considerations

### Data Scraping
- Check `robots.txt` before scraping any site
- Respect rate limits (1 request per second minimum)
- Review Terms of Service
- Credit data sources in app

### Using Manufacturer Data
- Most manufacturers appreciate attribution
- Consider reaching out for official partnership
- Some may provide official images/assets

### User-Submitted Content
- Implement terms of service for user submissions
- Allow users to report inaccurate data
- Consider moderation for community submissions

## Implementation Checklist

- [ ] Create JSON schema for discs and courses
- [ ] Manually enter seed data for 50+ popular discs
- [ ] Set up SQLite database in app
- [ ] Implement search/filter by flight numbers
- [ ] Add course location using OpenStreetMap or Google Places API
- [ ] Create user data submission form
- [ ] Implement local caching for offline use
- [ ] Add image loading/caching from manufacturer URLs
