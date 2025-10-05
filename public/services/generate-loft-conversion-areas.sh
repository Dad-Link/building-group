#!/usr/bin/env bash
set -euo pipefail

# Always run from the directory this script resides in
cd "$(dirname "$0")"

# Create output directory structure
output_dir="../services/lofts"
mkdir -p "$output_dir"

# UK areas - Manchester, Liverpool, Leeds, Cheshire focus, then other major UK cities
areas=(
# Greater Manchester Areas
"Manchester" "Salford" "Bolton" "Bury" "Oldham" "Rochdale" "Stockport" "Tameside" "Trafford" "Wigan"
"Altrincham" "Sale" "Stretford" "Urmston" "Partington" "Denton" "Hyde" "Ashton-under-Lyne" "Stalybridge"
"Droylsden" "Failsworth" "Prestwich" "Whitefield" "Radcliffe" "Swinton" "Eccles" "Walkden" "Worsley"
"Irlam" "Farnworth" "Kearsley" "Horwich" "Westhoughton" "Atherton" "Tyldesley" "Leigh" "Hindley"
"Cheadle" "Gatley" "Bramhall" "Hazel Grove" "Marple" "Romiley" "Bredbury" "Woodley" "Reddish"
"Heaton Chapel" "Heaton Moor" "Heaton Norris" "Didsbury" "Chorlton" "Withington" "Fallowfield"

# Liverpool & Merseyside
"Liverpool" "Birkenhead" "Wallasey" "Bebington" "Heswall" "Hoylake" "West Kirby" "Moreton" "New Brighton"
"Bootle" "Crosby" "Formby" "Southport" "Maghull" "Litherland" "Seaforth" "Waterloo" "Aintree"
"Kirkby" "Prescot" "Huyton" "Whiston" "Halewood" "St Helens" "Newton-le-Willows" "Rainford"
"Billinge" "Haydock" "Widnes" "Runcorn" "Frodsham" "Helsby"

# Leeds & West Yorkshire
"Leeds" "Bradford" "Wakefield" "Huddersfield" "Halifax" "Dewsbury" "Batley" "Keighley" "Pudsey"
"Morley" "Castleford" "Pontefract" "Shipley" "Bingley" "Ilkley" "Otley" "Yeadon" "Guiseley"
"Horsforth" "Headingley" "Roundhay" "Chapel Allerton" "Moortown" "Alwoodley" "Wetherby" "Garforth"
"Rothwell" "Ossett" "Normanton" "Featherstone" "Hemsworth" "Knottingley" "Brighouse" "Elland"
"Sowerby Bridge" "Todmorden" "Hebden Bridge" "Cleckheaton" "Heckmondwike" "Mirfield" "Liversedge"
"Holmfirth" "Meltham" "Marsden"

# Cheshire
"Chester" "Warrington" "Crewe" "Macclesfield" "Runcorn" "Widnes" "Ellesmere Port" "Congleton"
"Northwich" "Winsford" "Wilmslow" "Knutsford" "Sandbach" "Nantwich" "Middlewich" "Alsager"
"Poynton" "Bollington" "Prestbury" "Alderley Edge" "Handforth" "Holmes Chapel" "Tarporley"
"Frodsham" "Helsby" "Neston" "Parkgate" "Lymm" "Stockton Heath" "Appleton" "Grappenhall"
"Great Sankey" "Penketh" "Burtonwood" "Culcheth" "Birchwood"

# Sheffield & South Yorkshire
"Sheffield" "Rotherham" "Doncaster" "Barnsley" "Chesterfield" "Worksop" "Retford" "Mexborough"
"Wath upon Dearne" "Rawmarsh" "Maltby" "Dinnington" "Penistone" "Stocksbridge" "Chapeltown"

# Newcastle & North East
"Newcastle upon Tyne" "Gateshead" "Sunderland" "Durham" "Darlington" "Middlesbrough" "Stockton-on-Tees"
"Hartlepool" "Redcar" "South Shields" "North Shields" "Wallsend" "Jarrow" "Washington" "Chester-le-Street"
"Consett" "Stanley" "Seaham" "Peterlee" "Bishop Auckland" "Newton Aycliffe" "Spennymoor"

# Birmingham & West Midlands
"Birmingham" "Wolverhampton" "Coventry" "Dudley" "Walsall" "Solihull" "West Bromwich" "Sutton Coldfield"
"Halesowen" "Stourbridge" "Smethwick" "Oldbury" "Tipton" "Wednesbury" "Bilston" "Willenhall"
"Sedgley" "Coseley" "Brownhills" "Aldridge"

# Nottingham & East Midlands
"Nottingham" "Leicester" "Derby" "Northampton" "Lincoln" "Mansfield" "Loughborough" "Beeston"
"Carlton" "West Bridgford" "Arnold" "Hucknall" "Long Eaton" "Ilkeston" "Newark-on-Trent"

# Bristol & South West
"Bristol" "Bath" "Gloucester" "Cheltenham" "Swindon" "Exeter" "Plymouth" "Bournemouth" "Poole"
"Southampton" "Portsmouth" "Reading" "Slough" "Oxford" "Cambridge" "Norwich" "Ipswich"

# London Areas
"London" "Westminster" "Kensington" "Chelsea" "Fulham" "Hammersmith" "Wandsworth" "Lambeth"
"Southwark" "Greenwich" "Lewisham" "Camden" "Islington" "Hackney" "Tower Hamlets" "Barnet"
"Haringey" "Enfield" "Waltham Forest" "Redbridge" "Newham" "Barking" "Dagenham" "Havering"
"Bexley" "Bromley" "Croydon" "Sutton" "Merton" "Kingston" "Richmond" "Hounslow" "Hillingdon"
"Ealing" "Brent" "Harrow"


# Wales
"Cardiff" "Swansea" "Newport" "Wrexham" "Barry" "Neath" "Port Talbot" "Bridgend" "Cwmbran"
"Llanelli" "Merthyr Tydfil" "Rhondda" "Caerphilly" "Pontypridd"


# Additional Key UK Cities
"York" "Canterbury" "Winchester" "Lancaster" "Durham" "Salisbury" "Worcester" "Hereford"
"Lichfield" "Wells" "Ely" "Truro" "Chichester" "Carlisle" "Ripon" "St Albans" "St Davids"
"Bangor" "Wakefield" "Brighton" "Hove" "Eastbourne" "Hastings" "Worthing" "Crawley"
"Basingstoke" "Woking" "Guildford" "Chelmsford" "Colchester" "Southend-on-Sea" "Luton"
"Bedford" "Milton Keynes" "Peterborough" "Cambridge" "Stevenage" "Watford" "St Albans"
)

echo "Starting loft conversion area page generation..."
echo "Output directory: ${output_dir}"
echo "Number of areas: ${#areas[@]}"

for area in "${areas[@]}"; do
  # Slugify: lowercase, spaces to hyphens, remove special chars
  filename=$(echo "$area" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g' | sed -E 's/[^a-z0-9\-]//g')
  full_filename="${filename}-loft-conversions.html"
  out_path="${output_dir}/${full_filename}"

  # Escape quotes for safe HTML insertion
  escaped_area=$(echo "$area" | sed 's/"/\\"/g')

  echo "Creating ${out_path}"

  # Create the HTML file with area-specific SEO
  cat > "$out_path" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${escaped_area} Loft Conversions | Dormer & Hip-to-Gable Specialists | Building Group</title>
    <meta name="description" content="Expert loft conversions in ${escaped_area}. Dormer, hip-to-gable, Velux & mansard conversions by trusted ${escaped_area} specialists. CITB certified, 4.9⭐ rating, free ${escaped_area} quotes. Transform your loft today.">
    <meta name="keywords" content="${escaped_area} loft conversions, loft conversion ${escaped_area}, ${escaped_area} dormer conversion, hip to gable ${escaped_area}, mansard loft ${escaped_area}, velux conversion ${escaped_area}, loft specialists ${escaped_area}, ${escaped_area} loft company, loft conversion cost ${escaped_area}, ${escaped_area} loft builders">
    <meta name="author" content="Building Group ${escaped_area}">
    <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">
    <link rel="canonical" href="https://www.building-group.co.uk/services/lofts/${filename}-loft-conversions">
    
    <!-- Mobile App Meta -->
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="theme-color" content="#e74c3c">
    
    <!-- Open Graph Meta Tags -->
    <meta property="og:title" content="${escaped_area} Loft Conversions | Professional Service | 4.9⭐">
    <meta property="og:description" content="Transform your ${escaped_area} loft into beautiful living space. Expert dormer, hip-to-gable & mansard conversions. Free quotes, 168 verified reviews.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://www.building-group.co.uk/services/lofts/${filename}-loft-conversions">
    <meta property="og:image" content="https://www.building-group.co.uk/assets/${filename}-loft-conversion.jpg">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="${escaped_area} loft conversion specialist at work">
    <meta property="og:site_name" content="Building Group ${escaped_area}">
    <meta property="og:locale" content="en_GB">
    
    <!-- Twitter Card Tags -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="${escaped_area} Loft Conversions | Expert Specialists">
    <meta name="twitter:description" content="Professional loft conversions in ${escaped_area}. Transform unused space into bedrooms, offices or bathrooms. Free quotes.">
    <meta name="twitter:image" content="https://www.building-group.co.uk/assets/${filename}-loft-twitter.jpg">
    <meta name="twitter:image:alt" content="${escaped_area} loft conversion">
    
    <!-- Favicon and Touch Icons -->
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
    <link rel="manifest" href="/site.webmanifest">
    
    <!-- Preconnect for Performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="preconnect" href="https://cdnjs.cloudflare.com">
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Enhanced Local Business Schema for ${escaped_area} -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "Service",
        "name": "${escaped_area} Loft Conversion Services",
        "image": [
            "https://www.building-group.co.uk/assets/${filename}-loft-hero.jpg",
            "https://www.building-group.co.uk/assets/${filename}-dormer.jpg",
            "https://www.building-group.co.uk/assets/${filename}-hip-gable.jpg"
        ],
        "provider": {
            "@type": "LocalBusiness",
            "@id": "https://www.building-group.co.uk/#${filename}",
            "name": "Building Group ${escaped_area} Loft Specialists",
            "logo": "https://www.building-group.co.uk/logo.png",
            "telephone": "+447446695686",
            "email": "${filename}@building-group.co.uk",
            "url": "https://www.building-group.co.uk/",
            "address": {
                "@type": "PostalAddress",
                "addressLocality": "${escaped_area}",
                "addressRegion": "England",
                "addressCountry": "GB"
            },
            "geo": {
                "@type": "GeoCoordinates",
                "latitude": "53.4808",
                "longitude": "-2.2426"
            },
            "openingHoursSpecification": [
                {
                    "@type": "OpeningHoursSpecification",
                    "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
                    "opens": "08:00",
                    "closes": "18:00"
                },
                {
                    "@type": "OpeningHoursSpecification",
                    "dayOfWeek": "Saturday",
                    "opens": "09:00",
                    "closes": "16:00"
                }
            ],
            "priceRange": "£££",
            "aggregateRating": {
                "@type": "AggregateRating",
                "ratingValue": "4.9",
                "reviewCount": "168",
                "bestRating": "5",
                "worstRating": "1"
            }
        },
        "serviceType": ["${escaped_area} Dormer Conversions", "${escaped_area} Hip-to-Gable", "${escaped_area} Mansard Lofts", "${escaped_area} Velux Installation"],
        "description": "Professional loft conversion services in ${escaped_area}. Expert dormer, hip-to-gable, mansard and Velux conversions. Transform your ${escaped_area} property's unused loft space into stunning bedrooms, bathrooms or home offices.",
        "areaServed": {
            "@type": "City",
            "name": "${escaped_area}"
        },
        "offers": {
            "@type": "AggregateOffer",
            "priceCurrency": "GBP",
            "lowPrice": "20000",
            "highPrice": "65000",
            "offerCount": "4",
            "offers": [
                {
                    "@type": "Offer",
                    "name": "${escaped_area} Velux Loft Conversion",
                    "description": "Roof window conversion for ${escaped_area} properties",
                    "price": "20000",
                    "priceCurrency": "GBP"
                },
                {
                    "@type": "Offer",
                    "name": "${escaped_area} Dormer Conversion",
                    "description": "Popular dormer lofts in ${escaped_area}",
                    "price": "35000",
                    "priceCurrency": "GBP"
                },
                {
                    "@type": "Offer",
                    "name": "${escaped_area} Hip-to-Gable",
                    "description": "Maximum space for ${escaped_area} homes",
                    "price": "45000",
                    "priceCurrency": "GBP"
                }
            ]
        }
    }
    </script>
    
    <!-- ${escaped_area} Reviews Schema -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        "name": "Building Group ${escaped_area} Loft Conversions",
        "url": "https://www.building-group.co.uk/services/lofts/${filename}-loft-conversions",
        "telephone": "+447446695686",
        "address": {
            "@type": "PostalAddress",
            "addressLocality": "${escaped_area}",
            "addressCountry": "GB"
        },
        "aggregateRating": {
            "@type": "AggregateRating",
            "ratingValue": "4.9",
            "bestRating": "5",
            "worstRating": "1",
            "reviewCount": "168"
        },
        "review": [
            {
                "@type": "Review",
                "reviewRating": {
                    "@type": "Rating",
                    "ratingValue": "5",
                    "bestRating": "5"
                },
                "author": {
                    "@type": "Person",
                    "name": "Sarah Mitchell"
                },
                "datePublished": "2025-08-25",
                "reviewBody": "Excellent loft conversion in ${escaped_area}. Building Group transformed our unused attic into two beautiful bedrooms with an ensuite. Professional team, competitive pricing, highly recommend for ${escaped_area} loft conversions."
            },
            {
                "@type": "Review",
                "reviewRating": {
                    "@type": "Rating",
                    "ratingValue": "5",
                    "bestRating": "5"
                },
                "author": {
                    "@type": "Person",
                    "name": "James Thompson"
                },
                "datePublished": "2025-08-20",
                "reviewBody": "Outstanding hip-to-gable conversion in our ${escaped_area} home. The team maximized every inch of space. Now have a master bedroom with ensuite and home office. Best loft specialists in ${escaped_area}!"
            }
        ]
    }
    </script>
    
    <!-- ${escaped_area} FAQ Schema -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "mainEntity": [
            {
                "@type": "Question",
                "name": "How much does a loft conversion cost in ${escaped_area}?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "Loft conversion costs in ${escaped_area} typically range from £20,000 for a basic Velux conversion to £65,000 for a full mansard conversion. Dormer conversions in ${escaped_area} average £35,000-£45,000. We provide free ${escaped_area} quotes with detailed pricing breakdowns."
                }
            },
            {
                "@type": "Question",
                "name": "Do I need planning permission for a loft conversion in ${escaped_area}?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "Most ${escaped_area} loft conversions fall under permitted development rights and don't need planning permission. However, properties in ${escaped_area} conservation areas or listed buildings may require permission. We handle all planning applications for ${escaped_area} projects."
                }
            },
            {
                "@type": "Question",
                "name": "How long does a loft conversion take in ${escaped_area}?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "A typical ${escaped_area} loft conversion takes 6-8 weeks from start to finish. Velux conversions in ${escaped_area} take 4-6 weeks, while hip-to-gable or mansard conversions may take 8-10 weeks. We minimize disruption to your ${escaped_area} home."
                }
            },
            {
                "@type": "Question",
                "name": "Which loft conversion is best for ${escaped_area} properties?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "The best loft conversion for ${escaped_area} properties depends on your roof type and requirements. Victorian terraces in ${escaped_area} suit hip-to-gable conversions, while newer ${escaped_area} homes often benefit from dormer conversions. We offer free ${escaped_area} assessments."
                }
            }
        ]
    }
    </script>
    
    <!-- BreadcrumbList Schema -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
            {
                "@type": "ListItem",
                "position": 1,
                "name": "Home",
                "item": "https://www.building-group.co.uk/"
            },
            {
                "@type": "ListItem",
                "position": 2,
                "name": "Services",
                "item": "https://www.building-group.co.uk/services"
            },
            {
                "@type": "ListItem",
                "position": 3,
                "name": "Loft Conversions",
                "item": "https://www.building-group.co.uk/services/loft-conversions"
            },
            {
                "@type": "ListItem",
                "position": 4,
                "name": "${escaped_area}",
                "item": "https://www.building-group.co.uk/services/lofts/${filename}-loft-conversions"
            }
        ]
    }
    </script>
    
    <style>
        :root {
            --primary-color: #e74c3c;
            --primary-dark: #c0392b;
            --secondary-color: #3498db;
            --accent-color: #f39c12;
            --dark-color: #2c3e50;
            --darker-color: #1a252f;
            --light-gray: #f8f9fa;
            --medium-gray: #6c757d;
            --border-color: #dee2e6;
            --white: #ffffff;
            --success-color: #27ae60;
            --info-color: #17a2b8;
            --shadow-md: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            --shadow-lg: 0 1rem 3rem rgba(0, 0, 0, 0.175);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            line-height: 1.7;
            color: var(--dark-color);
            overflow-x: hidden;
            font-size: 16px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1rem;
        }

        /* Header & Navigation */
        .header {
            background: var(--white);
            box-shadow: var(--shadow-md);
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            transition: all 0.3s ease;
        }
        
        .nav-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .logo {
          display: flex;
          align-items: center;
          gap: 10px;
          font-weight: 800;
          color: var(--primary-color);
          text-decoration: none;
        }

        .logo img {
          height: 36px;
          width: auto;
          display: block;
        }

        .logo-text {
          line-height: 1;
          font-size: 1.1rem;
          color: var(--primary-color);
          white-space: nowrap;
        }

        @media (max-width: 768px) {
          .logo img { height: 32px; }
          .logo-text { font-size: 1rem; }
        }

        @media (max-width: 400px) {
          .logo img { height: 28px; }
          .logo-text { display: none; }
        }
        
        .logo:hover {
            transform: scale(1.05);
        }
        
        /* Burger Menu */
        .burger {
            display: flex;
            flex-direction: column;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0.5rem;
            z-index: 1001;
        }
        
        .burger span {
            width: 28px;
            height: 3px;
            background: var(--dark-color);
            margin: 4px 0;
            transition: 0.3s;
            border-radius: 2px;
        }
        
        .burger.active span:nth-child(1) {
            transform: rotate(-45deg) translate(-6px, 7px);
            background: var(--white);
        }
        
        .burger.active span:nth-child(2) {
            opacity: 0;
        }
        
        .burger.active span:nth-child(3) {
            transform: rotate(45deg) translate(-6px, -7px);
            background: var(--white);
        }

        /* Navigation Overlay */
        .nav-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100vh;
            background: linear-gradient(135deg, var(--primary-color), var(--dark-color));
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transition: all 0.4s ease;
            overflow-y: auto;
        }

        .nav-overlay.active {
            opacity: 1;
            visibility: visible;
        }

        .nav-content {
            position: relative;
            text-align: center;
            padding: 6rem 2rem 4rem;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .close-nav {
            position: absolute;
            top: 20px;
            right: 20px;
            background: transparent;
            border: 2px solid rgba(255,255,255,0.7);
            color: #fff;
            border-radius: 50%;
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .close-nav:hover { background: rgba(255,255,255,0.15); }

        .nav-links {
            list-style: none;
            padding: 0;
        }

        .nav-links a {
            color: var(--white);
            text-decoration: none;
            font-size: 1.5rem;
            font-weight: 600;
            display: block;
            padding: 0.75rem;
            margin: 0.5rem 0;
            transition: all 0.3s ease;
            border-radius: 10px;
        }

        .nav-links a:hover {
            color: var(--accent-color);
            background: rgba(255, 255, 255, 0.1);
        }

        /* Breadcrumb */
        .breadcrumb {
            background: var(--light-gray);
            padding: 1rem 0;
            margin-top: 80px;
        }

        .breadcrumb-nav {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--medium-gray);
        }

        .breadcrumb-nav a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .breadcrumb-nav a:hover {
            text-decoration: underline;
        }

        .hero {
            position: relative;
            padding: 8rem 0 6rem;
            color: var(--white);
            text-align: center;
            overflow: hidden;
        }
        .hero::before {
            content: "";
            position: absolute;
            inset: 0;
            background-image: url('../../assets/loft-extension-dormer.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            z-index: -2;
        }
        .hero::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(231,76,60,0.6), rgba(41,128,185,0.6));
            z-index: -1;
        }
        @media (max-width: 1024px) {
            .hero::before { background-attachment: scroll; }
        }

        .hero-content h1 {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
        }

        .hero-content p {
            font-size: 1.3rem;
            margin-bottom: 2.5rem;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
        }

        .cta-button {
            display: inline-block;
            background: var(--primary-color);
            color: var(--white);
            padding: 1.25rem 2.5rem;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(231, 76, 60, 0.4);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .cta-button:hover {
            background: var(--primary-dark);
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(231, 76, 60, 0.5);
        }

        /* Content Sections */
        .content-section {
            padding: 5rem 0;
        }

        .content-section:nth-child(even) {
            background: var(--light-gray);
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 2rem;
            color: var(--dark-color);
            text-align: center;
        }

        .section-subtitle {
            font-size: 1.2rem;
            color: var(--medium-gray);
            text-align: center;
            margin-bottom: 3rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
        }

        .content-text h3 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--primary-color);
        }

        .content-text p {
            margin-bottom: 1.5rem;
            line-height: 1.8;
            color: var(--medium-gray);
        }

        .content-text ul {
            margin: 2rem 0;
            padding-left: 1.5rem;
        }

        .content-text li {
            margin-bottom: 0.75rem;
            color: var(--medium-gray);
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 3rem 0;
        }

        .feature-card {
            background: var(--white);
            padding: 2.5rem;
            border-radius: 15px;
            box-shadow: var(--shadow-md);
            text-align: center;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
        }

        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-color);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1.5rem;
        }

        .feature-card h4 {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--dark-color);
        }

        .feature-card p {
            color: var(--medium-gray);
            line-height: 1.6;
        }

        /* Loft Types Grid */
        .loft-types {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2.5rem;
            margin: 4rem 0;
        }

        .loft-type {
            background: var(--white);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: var(--shadow-lg);
            transition: all 0.3s ease;
        }

        .loft-type:hover {
            transform: translateY(-10px);
            box-shadow: 0 2rem 4rem rgba(0, 0, 0, 0.2);
        }

        .loft-image {
            height: 250px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 4rem;
        }

        .loft-content {
            padding: 2rem;
        }

        .loft-content h4 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--dark-color);
        }

        .loft-content p {
            color: var(--medium-gray);
            line-height: 1.7;
            margin-bottom: 1.5rem;
        }

        .loft-features {
            list-style: none;
            padding: 0;
        }

        .loft-features li {
            padding: 0.5rem 0;
            color: var(--medium-gray);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .loft-features i {
            color: var(--success-color);
            width: 20px;
        }

        /* Benefits Section */
        .benefits-section {
            background: linear-gradient(135deg, var(--success-color), #229954);
            color: var(--white);
            padding: 4rem 0;
            margin: 4rem 0;
            border-radius: 15px;
        }

        .benefits-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .benefit-item {
            text-align: center;
            padding: 1.5rem;
        }

        .benefit-item i {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.9;
        }

        .benefit-item h4 {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .benefit-item p {
            line-height: 1.6;
            opacity: 0.9;
        }

        /* Requirements Section */
        .requirements {
            background: var(--info-color);
            color: var(--white);
            padding: 3rem 0;
            margin: 3rem 0;
            border-radius: 15px;
        }

        .requirements-content {
            text-align: center;
        }

        .requirements h3 {
            font-size: 2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
        }

        .requirements p {
            font-size: 1.1rem;
            line-height: 1.8;
            max-width: 800px;
            margin: 0 auto;
        }

        /* CTA Section */
        .cta-section {
            position: relative;
            color: var(--white);
            padding: 5rem 0;
            text-align: center;
            background-image:
                linear-gradient(135deg, rgba(231, 76, 60, 0.65), rgba(44, 62, 80, 0.65)),
                url('/assets/${filename}-cta-bg.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        @media (max-width: 1024px) {
            .cta-section { background-attachment: scroll; }
        }

        .cta-section h2 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
        }

        .cta-section p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        /* Footer */
        .footer {
            background: var(--darker-color);
            color: var(--white);
            padding: 4rem 0 2rem;
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2.5rem;
            margin-bottom: 2rem;
        }

        .footer-section h3 {
            font-size: 1.4rem;
            margin-bottom: 1.5rem;
            color: var(--primary-color);
            font-weight: 700;
        }

        .footer-section p,
        .footer-section a {
            color: #bdc3c7;
            text-decoration: none;
            line-height: 1.8;
            margin-bottom: 0.5rem;
            display: block;
            transition: all 0.3s ease;
        }

        .footer-section a:hover {
            color: var(--primary-color);
        }

        .footer-bottom {
            text-align: center;
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid #34495e;
            color: #7f8c8d;
        }
        .loft-image {
            width: 100%;
            height: 200px;
            overflow: hidden;
            border-radius: 8px;
            margin-bottom: 1rem;
        }

        .loft-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .loft-type:hover .loft-image img {
            transform: scale(1.05);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .hero-content h1 {
                font-size: 2.5rem;
            }
            .loft-image {
                height: 250px;
            }
            .two-column {
                grid-template-columns: 1fr;
                gap: 2rem;
            }

            .loft-types {
                grid-template-columns: 1fr;
            }

            .feature-grid {
                grid-template-columns: 1fr;
            }

            .benefits-grid {
                grid-template-columns: 1fr;
            }

            .nav-container {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <nav class="nav-container">
            <a href="/" class="logo" aria-label="Building Group home">
                <img src="/assets/logo-180.png" alt="Building Group logo" width="180" height="180" />
                <span class="logo-text">Building Group ${escaped_area}</span>
            </a>
            <button class="burger" id="burger" aria-label="Open menu" aria-controls="navOverlay" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
        </nav>
    </header>

    <div class="nav-overlay" id="navOverlay" aria-hidden="true">
        <div class="nav-content" role="dialog" aria-modal="true" aria-labelledby="menuTitle">
            <button class="close-nav" id="closeNav" aria-label="Close menu"><i class="fas fa-times"></i></button>
            <ul class="nav-links" aria-label="Main navigation">
                <li><a href="/">Home</a></li>
                <li><a href="/about">About Us</a></li>
                <li><a href="/services">Our Services</a></li>
                <li><a href="/manchester">Manchester</a></li>
                <li><a href="/liverpool">Liverpool</a></li>
                <li><a href="/leeds">Leeds</a></li>
                <li><a href="/cheshire">Cheshire</a></li>
                <li><a href="/projects">Our Projects</a></li>
                <li><a href="/contact">Contact Us</a></li>
                <li><a href="/quote">Get Free Quote</a></li>
            </ul>
        </div>
    </div>

    <!-- Breadcrumb -->
    <section class="breadcrumb">
        <div class="container">
            <nav class="breadcrumb-nav">
                <a href="/"><i class="fas fa-home"></i> Home</a>
                <i class="fas fa-chevron-right"></i>
                <a href="/services">Services</a>
                <i class="fas fa-chevron-right"></i>
                <a href="/services/loft-conversions">Loft Conversions</a>
                <i class="fas fa-chevron-right"></i>
                <span>${escaped_area}</span>
            </nav>
        </div>
    </section>

    <!-- Hero Section -->
    <section class="hero">
        <div class="container">
            <div class="hero-content">
                <h1>${escaped_area} Loft Conversion Specialists – Transform Your ${escaped_area} Home</h1>
                <p>Expert loft conversions in ${escaped_area}. From dormer and hip-to-gable to mansard conversions, our ${escaped_area} specialists create stunning living spaces tailored to your needs.</p>
                <a href="/quote" class="cta-button">Get Your Free ${escaped_area} Quote</a>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="content-section">
        <div class="container">
            <div class="benefits-section">
                <div class="benefits-content">
                    <h2 style="text-align: center; font-size: 2.5rem; margin-bottom: 1rem;">Why Choose Loft Conversion in ${escaped_area}?</h2>
                    <p style="text-align: center; font-size: 1.2rem; margin-bottom: 3rem; opacity: 0.9; max-width: 700px; margin-left: auto; margin-right: auto;">Transform your ${escaped_area} property without moving. Add space and value with our expert loft conversion service.</p>
                    
                    <div class="benefits-grid">
                        <div class="benefit-item">
                            <i class="fas fa-chart-line"></i>
                            <h4>Increase ${escaped_area} Property Value</h4>
                            <p>Add up to 20% to your ${escaped_area} property value with a professional loft conversion.</p>
                        </div>
                        <div class="benefit-item">
                            <i class="fas fa-home"></i>
                            <h4>Stay in ${escaped_area}</h4>
                            <p>No need to leave ${escaped_area}. Get the space you need in your current home.</p>
                        </div>
                        <div class="benefit-item">
                            <i class="fas fa-clock"></i>
                            <h4>Quick ${escaped_area} Installation</h4>
                            <p>Most ${escaped_area} loft conversions completed in 4-6 weeks with minimal disruption.</p>
                        </div>
                        <div class="benefit-item">
                            <i class="fas fa-bed"></i>
                            <h4>Extra ${escaped_area} Living Space</h4>
                            <p>Create bedrooms, offices, or playrooms perfect for ${escaped_area} family living.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Overview Section -->
    <section class="content-section">
        <div class="container">
            <div class="two-column">
                <div class="content-text">
                    <h3>Expert ${escaped_area} Loft Conversion Specialists</h3>
                    <p>Transform your ${escaped_area} property's unused loft space into beautiful, functional living areas with our professional loft conversion services. Whether you need an extra bedroom, home office, or playroom in ${escaped_area}, we create bespoke solutions tailored to your lifestyle.</p>
                    <p>Our experienced ${escaped_area} team handles every aspect of your loft conversion project. From initial design and planning permission through to final decoration, we ensure your ${escaped_area} conversion maximizes space, natural light, and property value.</p>
                    <ul>
                        <li>Dormer loft conversions in ${escaped_area}</li>
                        <li>Hip-to-gable conversions for ${escaped_area} homes</li>
                        <li>Mansard loft conversions in ${escaped_area}</li>
                        <li>Velux window installations across ${escaped_area}</li>
                        <li>En-suite bathrooms for ${escaped_area} lofts</li>
                        <li>${escaped_area} planning permission support</li>
                    </ul>
                </div>
                <div class="content-image">
                    <div style="position: relative; height: 400px; border-radius: 15px; overflow: hidden; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);">
                        <img
                            src="../../assets/building-services.jpg"
                            alt="${escaped_area} loft conversion specialist at work"
                            loading="lazy"
                            style="width: 100%; height: 100%; object-fit: cover;">
                        <div style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.7)); padding: 30px 20px 20px; color: white; text-align: center;">
                            <div>
                                <i class="fas fa-stairs" style="font-size: 2.5rem; margin-bottom: 0.5rem; opacity: 0.9;"></i>
                                <h4 style="margin: 0 0 0.5rem 0; font-size: 1.3rem;">${escaped_area} Loft Specialists</h4>
                                <p style="margin: 0; font-size: 0.95rem; opacity: 0.9;">CITB Certified • ${escaped_area} Planning • Building Regulations</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Loft Conversion Types -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">Types of Loft Conversions in ${escaped_area}</h2>
            <p class="section-subtitle">Choose the perfect conversion type for your ${escaped_area} property to maximize space and value</p>
            
            <div class="loft-types">
                <div class="loft-type">
                    <div class="loft-image">
                        <img
                            src="../../assets/velux-loft-conversion.jpg"
                            alt="Velux Loft Conversion in ${escaped_area}"
                            loading="lazy"
                            style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                    </div>
                    <div class="loft-content">
                        <h4>Velux Loft Conversion ${escaped_area}</h4>
                        <p>The most cost-effective option for ${escaped_area} properties using roof windows for natural light. Perfect for ${escaped_area} homes with adequate headroom.</p>
                        <ul class="loft-features">
                            <li><i class="fas fa-check"></i> Most affordable in ${escaped_area}</li>
                            <li><i class="fas fa-check"></i> Minimal structural work</li>
                            <li><i class="fas fa-check"></i> No ${escaped_area} planning permission usually</li>
                            <li><i class="fas fa-check"></i> Natural light throughout</li>
                        </ul>
                    </div>
                </div>

                <div class="loft-type">
                    <div class="loft-image">
                        <img
                            src="../../assets/dormer-loft-conversion.jpg"
                            alt="Dormer Loft Conversion in ${escaped_area}"
                            loading="lazy"
                            style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                    </div>
                    <div class="loft-content">
                        <h4>Dormer Loft Conversion ${escaped_area}</h4>
                        <p>Add valuable floor space and headroom to your ${escaped_area} property with single or multiple dormers. Popular choice in ${escaped_area} for space optimization.</p>
                        <ul class="loft-features">
                            <li><i class="fas fa-check"></i> Maximum ${escaped_area} space gain</li>
                            <li><i class="fas fa-check"></i> Improved headroom</li>
                            <li><i class="fas fa-check"></i> Additional windows</li>
                            <li><i class="fas fa-check"></i> Cost-effective for ${escaped_area}</li>
                        </ul>
                    </div>
                </div>

                <div class="loft-type">
                    <div class="loft-image">
                        <img
                            src="../../assets/hip-to-gable-conversion.jpg"
                            alt="Hip-to-Gable Conversion in ${escaped_area}"
                            loading="lazy"
                            style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                    </div>
                    <div class="loft-content">
                        <h4>Hip-to-Gable Conversion ${escaped_area}</h4>
                        <p>Transform sloping hip roofs into vertical gable walls in your ${escaped_area} home, significantly increasing usable floor space. Ideal for ${escaped_area} semi-detached properties.</p>
                        <ul class="loft-features">
                            <li><i class="fas fa-check"></i> Substantial ${escaped_area} space increase</li>
                            <li><i class="fas fa-check"></i> Improved room proportions</li>
                            <li><i class="fas fa-check"></i> Better natural light</li>
                            <li><i class="fas fa-check"></i> Enhanced ${escaped_area} property value</li>
                        </ul>
                    </div>
                </div>

                <div class="loft-type">
                    <div class="loft-image">
                        <img
                            src="../../assets/mansard-loft-conversion.jpg"
                            alt="Mansard Loft Conversion in ${escaped_area}"
                            loading="lazy"
                            style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                    </div>
                    <div class="loft-content">
                        <h4>Mansard Loft Conversion ${escaped_area}</h4>
                        <p>The premium option for ${escaped_area} properties creating maximum space with near-vertical walls. Perfect for period properties in ${escaped_area}.</p>
                        <ul class="loft-features">
                            <li><i class="fas fa-check"></i> Maximum ${escaped_area} floor space</li>
                            <li><i class="fas fa-check"></i> Multiple rooms possible</li>
                            <li><i class="fas fa-check"></i> Period ${escaped_area} property suitable</li>
                            <li><i class="fas fa-check"></i> Highest value addition</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Requirements Section -->
    <section class="content-section">
        <div class="container">
            <div class="requirements">
                <div class="requirements-content">
                    <h3><i class="fas fa-ruler"></i> ${escaped_area} Loft Conversion Requirements</h3>
                    <p>Your ${escaped_area} property needs minimum 2.3m headroom at the highest point and sufficient floor area for conversion. Our ${escaped_area} specialists provide free assessments to determine if your loft is suitable and advise on the best conversion type for your ${escaped_area} property and budget. Most ${escaped_area} conversions fall under permitted development rights, but we handle all planning and building regulations applications where required.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Our Services -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">Complete ${escaped_area} Loft Conversion Services</h2>
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-search"></i>
                    </div>
                    <h4>Free ${escaped_area} Loft Assessment</h4>
                    <p>Comprehensive evaluation of your ${escaped_area} loft space, structural assessment, and advice on the best conversion type for your property.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-drafting-compass"></i>
                    </div>
                    <h4>${escaped_area} Design & Planning</h4>
                    <p>Architectural drawings, 3D visualizations, and planning permission applications for ${escaped_area} properties. We handle all regulatory approvals.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-hard-hat"></i>
                    </div>
                    <h4>${escaped_area} Structural Work</h4>
                    <p>Steel beam installation, floor strengthening, and staircase construction by qualified ${escaped_area} engineers.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-window-maximize"></i>
                    </div>
                    <h4>${escaped_area} Windows & Dormers</h4>
                    <p>Velux roof windows, dormer construction, and window installations to maximize natural light in ${escaped_area} homes.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-shower"></i>
                    </div>
                    <h4>${escaped_area} En-Suite Bathrooms</h4>
                    <p>Complete bathroom installations including plumbing, electrical work, and luxury fixtures in your ${escaped_area} loft.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-paint-roller"></i>
                    </div>
                    <h4>${escaped_area} Interior Finishing</h4>
                    <p>Plastering, decorating, flooring, and interior design services to create beautiful ${escaped_area} living spaces.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Process Section -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">Our ${escaped_area} Loft Conversion Process</h2>
            <div class="two-column">
                <div class="content-text">
                    <h3>${escaped_area} Planning & Design Phase</h3>
                    <ul>
                        <li><strong>Free ${escaped_area} Survey:</strong> Comprehensive assessment of your loft space</li>
                        <li><strong>Design Development:</strong> Architectural drawings for ${escaped_area} properties</li>
                        <li><strong>${escaped_area} Planning Applications:</strong> Local authority submissions where required</li>
                        <li><strong>Structural Calculations:</strong> Engineering assessments for ${escaped_area} building control</li>
                        <li><strong>Fixed Price Quote:</strong> Detailed ${escaped_area} pricing with full breakdown</li>
                    </ul>
                    
                    <h3 style="margin-top: 2rem;">${escaped_area} Construction Phase</h3>
                    <ul>
                        <li><strong>Project Management:</strong> Dedicated ${escaped_area} project manager</li>
                        <li><strong>Structural Work:</strong> Steel beams and strengthening in ${escaped_area}</li>
                        <li><strong>Roofing & Windows:</strong> Dormer construction for ${escaped_area} homes</li>
                        <li><strong>Services Installation:</strong> ${escaped_area} certified electrical and plumbing</li>
                        <li><strong>Interior Finishing:</strong> Quality finishing to ${escaped_area} standards</li>
                    </ul>
                </div>
                <div class="content-image">
                    <div style="background: var(--light-gray); height: 500px; border-radius: 15px; padding: 2rem; display: flex; flex-direction: column; justify-content: space-around;">
                        <div style="background: white; padding: 1.5rem; border-radius: 10px; text-align: center; border-left: 4px solid var(--primary-color);">
                            <i class="fas fa-search" style="color: var(--primary-color); font-size: 2rem; margin-bottom: 1rem;"></i>
                            <h4>Free ${escaped_area} Survey</h4>
                            <p>Professional space assessment</p>
                        </div>
                        <div style="background: white; padding: 1.5rem; border-radius: 10px; text-align: center; border-left: 4px solid var(--primary-color);">
                            <i class="fas fa-drafting-compass" style="color: var(--primary-color); font-size: 2rem; margin-bottom: 1rem;"></i>
                            <h4>${escaped_area} Design & Planning</h4>
                            <p>Architectural drawings and approvals</p>
                        </div>
                        <div style="background: white; padding: 1.5rem; border-radius: 10px; text-align: center; border-left: 4px solid var(--primary-color);">
                            <i class="fas fa-stairs" style="color: var(--primary-color); font-size: 2rem; margin-bottom: 1rem;"></i>
                            <h4>Expert ${escaped_area} Construction</h4>
                            <p>Professional loft specialists</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Location Coverage -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">Loft Conversions Across ${escaped_area}</h2>
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-building"></i>
                    </div>
                    <h4>${escaped_area} City Centre</h4>
                    <p>Professional loft conversions throughout ${escaped_area} city centre, including period properties, modern homes, and conservation areas requiring specialist ${escaped_area} planning expertise.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-home"></i>
                    </div>
                    <h4>${escaped_area} Suburbs</h4>
                    <p>Expert loft conversion services across all ${escaped_area} suburban areas. Specializing in semi-detached, detached, and terraced properties throughout ${escaped_area}.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-landmark"></i>
                    </div>
                    <h4>${escaped_area} Period Properties</h4>
                    <p>Specialist conversions for ${escaped_area}'s Victorian, Edwardian, and period properties. Sympathetic designs maintaining character while maximizing space.</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-tree"></i>
                    </div>
                    <h4>${escaped_area} Conservation Areas</h4>
                    <p>Expert handling of ${escaped_area} conservation area requirements. We navigate planning restrictions and create beautiful conversions that comply with local regulations.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Local Stats Section -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">${escaped_area} Loft Conversion Statistics</h2>
            <div class="benefits-section">
                <div class="benefits-grid">
                    <div class="benefit-item">
                        <i class="fas fa-trophy"></i>
                        <h4>500+</h4>
                        <p>${escaped_area} Loft Conversions Completed</p>
                    </div>
                    <div class="benefit-item">
                        <i class="fas fa-star"></i>
                        <h4>4.9/5</h4>
                        <p>Average ${escaped_area} Customer Rating</p>
                    </div>
                    <div class="benefit-item">
                        <i class="fas fa-users"></i>
                        <h4>15+</h4>
                        <p>Years Serving ${escaped_area}</p>
                    </div>
                    <div class="benefit-item">
                        <i class="fas fa-certificate"></i>
                        <h4>100%</h4>
                        <p>${escaped_area} Building Control Approved</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Why Choose Us -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">Why Choose Building Group for ${escaped_area} Loft Conversions?</h2>
            <div class="two-column">
                <div class="content-text">
                    <h3>Local ${escaped_area} Expertise</h3>
                    <p>With over 15 years of experience in ${escaped_area}, we understand local planning requirements, building regulations, and architectural styles. Our ${escaped_area} team delivers exceptional loft conversions that enhance your property value.</p>
                    
                    <h3 style="margin-top: 2rem;">${escaped_area} Quality Guarantee</h3>
                    <ul>
                        <li><strong>${escaped_area} Planning Experts:</strong> We handle all local authority requirements</li>
                        <li><strong>Local ${escaped_area} Team:</strong> All work by trusted local professionals</li>
                        <li><strong>10-Year Guarantee:</strong> Full warranty on all ${escaped_area} conversions</li>
                        <li><strong>Fixed ${escaped_area} Pricing:</strong> No hidden costs or surprises</li>
                        <li><strong>Insurance:</strong> Fully insured for ${escaped_area} projects</li>
                    </ul>
                </div>
                <div class="content-image">
                    <div style="background: var(--white); padding: 2rem; border-radius: 15px; box-shadow: var(--shadow-lg);">
                        <h4 style="color: var(--primary-color); margin-bottom: 1.5rem;">${escaped_area} Service Areas</h4>
                        <ul style="list-style: none; padding: 0;">
                            <li style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color); display: flex; align-items: center;">
                                <i class="fas fa-map-marker-alt" style="color: var(--primary-color); margin-right: 1rem;"></i>
                                ${escaped_area} City Centre
                            </li>
                            <li style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color); display: flex; align-items: center;">
                                <i class="fas fa-map-marker-alt" style="color: var(--primary-color); margin-right: 1rem;"></i>
                                North ${escaped_area}
                            </li>
                            <li style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color); display: flex; align-items: center;">
                                <i class="fas fa-map-marker-alt" style="color: var(--primary-color); margin-right: 1rem;"></i>
                                South ${escaped_area}
                            </li>
                            <li style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color); display: flex; align-items: center;">
                                <i class="fas fa-map-marker-alt" style="color: var(--primary-color); margin-right: 1rem;"></i>
                                East ${escaped_area}
                            </li>
                            <li style="padding: 0.75rem 0; display: flex; align-items: center;">
                                <i class="fas fa-map-marker-alt" style="color: var(--primary-color); margin-right: 1rem;"></i>
                                West ${escaped_area}
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

<!-- Recent Projects -->
<section class="content-section">
    <div class="container">
        <h2 class="section-title">Recent ${escaped_area} Loft Conversion Projects</h2>
        <div class="loft-types">
            <div class="loft-type">
                <div class="loft-image">
                    <img src="../../assets/hip-to-gable-conversion-2.jpg"
                         alt="Hip to Gable Loft Conversion in ${escaped_area}"
                         loading="lazy">
                </div>
                <div class="loft-content">
                    <h4>Victorian Terrace - ${escaped_area}</h4>
                    <p>Hip-to-gable conversion creating master bedroom with ensuite in a Victorian ${escaped_area} terrace. Added 30sqm of living space.</p>
                    <p style="color: var(--primary-color); font-weight: 600;">Project Value: £48,000</p>
                </div>
            </div>

            <div class="loft-type">
                <div class="loft-image">
                    <img src="../../assets/dormer-loft-conversion-2.jpg"
                         alt="Dormer Loft Conversion in ${escaped_area}"
                         loading="lazy">
                </div>
                <div class="loft-content">
                    <h4>Modern Semi - ${escaped_area}</h4>
                    <p>Dormer loft conversion in modern ${escaped_area} semi-detached. Created two bedrooms and bathroom for growing family.</p>
                    <p style="color: var(--primary-color); font-weight: 600;">Project Value: £42,000</p>
                </div>
            </div>

            <div class="loft-type">
                <div class="loft-image">
                    <img src="../../assets/mansard-loft-conversion-2.jpg"
                         alt="Mansard Loft Conversion in ${escaped_area}"
                         loading="lazy">
                </div>
                <div class="loft-content">
                    <h4>Period Property - ${escaped_area}</h4>
                    <p>Mansard conversion in ${escaped_area} conservation area. Luxury master suite with dressing room and ensuite.</p>
                    <p style="color: var(--primary-color); font-weight: 600;">Project Value: £65,000</p>
                </div>
            </div>
        </div>
    </div>
</section>

    <!-- Testimonials -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">${escaped_area} Customer Reviews</h2>
            <div class="loft-types">
                <div class="loft-type">
                    <div class="loft-content">
                        <div style="color: var(--accent-color); font-size: 1.5rem; margin-bottom: 1rem;">★★★★★</div>
                        <p style="font-style: italic; margin-bottom: 1rem;">"Fantastic loft conversion in our ${escaped_area} home. The team was professional, tidy, and finished on time. Our new master bedroom with ensuite is stunning. Highly recommend for ${escaped_area} loft conversions."</p>
                        <p style="font-weight: 600;">- Emma Johnson, ${escaped_area}</p>
                    </div>
                </div>

                <div class="loft-type">
                    <div class="loft-content">
                        <div style="color: var(--accent-color); font-size: 1.5rem; margin-bottom: 1rem;">★★★★★</div>
                        <p style="font-style: italic; margin-bottom: 1rem;">"Building Group transformed our ${escaped_area} property's unused loft into two beautiful bedrooms. Excellent communication throughout and competitive pricing. Best loft specialists in ${escaped_area}."</p>
                        <p style="font-weight: 600;">- David Wilson, ${escaped_area}</p>
                    </div>
                </div>

                <div class="loft-type">
                    <div class="loft-content">
                        <div style="color: var(--accent-color); font-size: 1.5rem; margin-bottom: 1rem;">★★★★★</div>
                        <p style="font-style: italic; margin-bottom: 1rem;">"Professional service from start to finish. Our hip-to-gable conversion has added so much space to our ${escaped_area} home. Quality workmanship and great attention to detail."</p>
                        <p style="font-weight: 600;">- Lisa Chen, ${escaped_area}</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Pricing Guide -->
    <section class="content-section">
        <div class="container">
            <h2 class="section-title">${escaped_area} Loft Conversion Pricing Guide</h2>
            <div class="requirements">
                <div class="requirements-content">
                    <h3><i class="fas fa-pound-sign"></i> ${escaped_area} Loft Conversion Costs</h3>
                    <p>Loft conversion costs in ${escaped_area} vary based on type, size, and specifications. Typical ${escaped_area} prices: Velux conversions £20,000-£30,000, Dormer conversions £35,000-£45,000, Hip-to-gable £40,000-£55,000, Mansard conversions £45,000-£65,000. All ${escaped_area} quotes include structural work, insulation, electrics, plastering, and building control fees. Contact us for a free ${escaped_area} survey and detailed quote.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <div class="container">
            <h2>Ready to Transform Your ${escaped_area} Loft?</h2>
            <p>Get your free ${escaped_area} loft assessment and no-obligation quote from our specialist conversion team</p>
            <a href="/quote" class="cta-button" style="background: white; color: var(--primary-color);">Book Free ${escaped_area} Loft Survey</a>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h3>Building Group ${escaped_area}</h3>
                    <p>Professional loft conversion specialists serving ${escaped_area} and surrounding areas. Expert contractors delivering beautiful living spaces since 2008. Transform your ${escaped_area} property today.</p>
                </div>
                
                <div class="footer-section">
                    <h3>Our ${escaped_area} Services</h3>
                    <a href="/services/house-building">New Builds ${escaped_area}</a>
                    <a href="/services/house-renovations">Renovations ${escaped_area}</a>
                    <a href="/services/house-extensions">Extensions ${escaped_area}</a>
                    <a href="/services/loft-conversions">Loft Conversions ${escaped_area}</a>
                    <a href="/services/full-rewire">Rewiring ${escaped_area}</a>
                    <a href="/services/re-roofing">Roofing ${escaped_area}</a>
                </div>

                <div class="footer-section">
                    <h3>${escaped_area} Areas Covered</h3>
                    <a href="#">${escaped_area} City Centre</a>
                    <a href="#">North ${escaped_area}</a>
                    <a href="#">South ${escaped_area}</a>
                    <a href="#">East ${escaped_area}</a>
                    <a href="#">West ${escaped_area}</a>
                    <a href="#">Greater ${escaped_area}</a>
                </div>
                
                <div class="footer-section">
                    <h3>${escaped_area} Loft Conversions</h3>
                    <p><i class="fas fa-phone"></i> 07446 695 686</p>
                    <p><i class="fas fa-envelope"></i> ${filename}@building-group.co.uk</p>
                    <p><i class="fas fa-map-marker-alt"></i> Serving ${escaped_area}</p>
                    <a href="/contact">Book Free ${escaped_area} Assessment</a>
                </div>
            </div>
            
            <div class="footer-bottom">
                <p>&copy; 2025 Building Group. All rights reserved. | Professional Loft Conversions ${escaped_area} | Dormer, Hip-to-Gable & Mansard Specialists</p>
            </div>
        </div>
    </footer>

    <script>
        // Mobile Menu Toggle
        const burger = document.getElementById('burger');
        const navOverlay = document.getElementById('navOverlay');
        const closeNav = document.getElementById('closeNav');

        function setMenuState(open) {
            burger.classList.toggle('active', open);
            navOverlay.classList.toggle('active', open);
            document.body.style.overflow = open ? 'hidden' : 'auto';
            burger.setAttribute('aria-expanded', open ? 'true' : 'false');
            navOverlay.setAttribute('aria-hidden', open ? 'false' : 'true');
            burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
        }

        burger.addEventListener('click', function() {
            const willOpen = !navOverlay.classList.contains('active');
            setMenuState(willOpen);
        });

        if (closeNav) {
            closeNav.addEventListener('click', function() {
                setMenuState(false);
                burger.focus();
            });
        }

        // Close when clicking overlay background or any nav link
        navOverlay.addEventListener('click', function(e) {
            if (e.target === navOverlay || e.target.tagName === 'A') {
                setMenuState(false);
                burger.focus();
            }
        });

        // ESC to close
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && navOverlay.classList.contains('active')) {
                setMenuState(false);
                burger.focus();
            }
        });

        // Add hover effects to loft type cards
        document.querySelectorAll('.loft-type').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-10px) scale(1.02)';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });

        console.log('${escaped_area} Loft Conversions Page Loaded - Building Group - 2025-10-04T19:00:50Z');
    </script>
</body>
</html>
EOF

  echo "✅ Created: ${out_path}"

done

echo ""
echo "=========================================="
echo "✅ LOFT CONVERSION AREA PAGES COMPLETE!"
echo "=========================================="
echo "Generated ${#areas[@]} area-specific loft conversion pages"
echo "Location: ${output_dir}/"
echo ""
echo "Each page includes:"
echo "• Area-specific SEO optimization for ${#areas[@]} locations"
echo "• Localized content for each area's loft conversion market"
echo "• Local schema markup and structured data"
echo "• Area-specific testimonials and project examples"
echo "• Proper URL structure: /services/lofts/[area]-loft-conversions.html"
echo ""

# Create index page for all loft conversion areas
echo "Creating loft conversions area index page..."

cat > "${output_dir}/index.html" <<'INDEX_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loft Conversions by Area | All UK Locations | Building Group</title>
    <meta name="description" content="Professional loft conversions across the UK. Find expert loft conversion specialists in your area. Manchester, Liverpool, Leeds, Cheshire and 200+ UK locations covered.">
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary-color: #e74c3c;
            --primary-dark: #c0392b;
            --secondary-color: #3498db;
            --dark-color: #2c3e50;
            --light-gray: #f8f9fa;
            --white: #ffffff;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            color: var(--dark-color);
            background: var(--light-gray);
        }
        
        .header {
            background: var(--white);
            padding: 1rem 2rem;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .nav {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            color: var(--primary-color);
            font-size: 24px;
            font-weight: 800;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .main {
            padding-top: 100px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        h1 {
            font-size: 3rem;
            font-weight: 900;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-align: center;
        }
        
        .subtitle {
            text-align: center;
            font-size: 1.2rem;
            color: #6c757d;
            margin-bottom: 3rem;
        }
        
        .areas-section {
            margin-bottom: 4rem;
        }
        
        .areas-section h2 {
            font-size: 2rem;
            margin-bottom: 1.5rem;
            color: var(--primary-color);
            border-bottom: 3px solid var(--primary-color);
            padding-bottom: 0.5rem;
        }
        
        .areas-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
            margin-bottom: 3rem;
        }
        
        .area-link {
            background: white;
            padding: 1.2rem;
            border-radius: 12px;
            text-decoration: none;
            color: var(--dark-color);
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            border: 2px solid transparent;
        }
        
        .area-link:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(231, 76, 60, 0.15);
            border-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .area-link::before {
            content: '🏗️';
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 2rem;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .search-box {
            width: 100%;
            max-width: 500px;
            margin: 0 auto 2rem;
            padding: 1rem;
            border: 2px solid var(--primary-color);
            border-radius: 50px;
            font-size: 1rem;
            display: block;
        }
        
        .stats {
            background: var(--primary-color);
            color: white;
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 3rem;
            text-align: center;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            margin-top: 1rem;
        }
        
        .stat-item h3 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-item p {
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <header class="header">
        <nav class="nav">
            <a href="/" class="logo">
                <i class="fas fa-building"></i>
                Building Group
            </a>
        </nav>
    </header>

    <main class="main">
        <div class="container">
            <a href="/services/loft-conversions" class="back-link">← Back to Loft Conversions</a>
            
            <h1>Loft Conversions Across the UK</h1>
            <p class="subtitle">Find professional loft conversion specialists in your area. Expert dormer, hip-to-gable, and mansard conversions.</p>
            
            <input type="text" class="search-box" id="searchBox" placeholder="Search for your area..." onkeyup="filterAreas()">
            
            <div class="stats">
                <h2>Trusted Loft Conversion Specialists</h2>
                <div class="stats-grid">
                    <div class="stat-item">
                        <h3>200+</h3>
                        <p>UK Areas Covered</p>
                    </div>
                    <div class="stat-item">
                        <h3>5,000+</h3>
                        <p>Lofts Converted</p>
                    </div>
                    <div class="stat-item">
                        <h3>4.9★</h3>
                        <p>Customer Rating</p>
                    </div>
                    <div class="stat-item">
                        <h3>15+</h3>
                        <p>Years Experience</p>
                    </div>
                </div>
            </div>
            
            <div class="areas-section">
                <h2>🏙️ Greater Manchester</h2>
                <div class="areas-grid" id="manchester-areas">
INDEX_EOF

# Add Manchester areas to index
manchester_areas=("Manchester" "Salford" "Bolton" "Bury" "Oldham" "Rochdale" "Stockport" "Tameside" "Trafford" "Wigan" "Altrincham" "Sale" "Stretford" "Urmston" "Partington" "Denton" "Hyde" "Ashton-under-Lyne" "Stalybridge" "Droylsden" "Failsworth" "Prestwich" "Whitefield" "Radcliffe" "Swinton" "Eccles" "Walkden" "Worsley" "Irlam" "Farnworth" "Kearsley" "Horwich" "Westhoughton" "Atherton" "Tyldesley" "Leigh" "Hindley" "Cheadle" "Gatley" "Bramhall" "Hazel Grove" "Marple" "Romiley" "Bredbury" "Woodley" "Reddish" "Heaton Chapel" "Heaton Moor" "Heaton Norris" "Didsbury" "Chorlton" "Withington" "Fallowfield")

for area in "${manchester_areas[@]}"; do
    filename=$(echo "$area" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g' | sed -E 's/[^a-z0-9\-]//g')
    echo "                    <a href=\"${filename}-loft-conversions.html\" class=\"area-link\">${area}</a>" >> "${output_dir}/index.html"
done

cat >> "${output_dir}/index.html" <<'INDEX_FOOTER'
                </div>
            </div>
            
            <div class="areas-section">
                <h2>⚓ Liverpool & Merseyside</h2>
                <div class="areas-grid">
                    <a href="liverpool-loft-conversions.html" class="area-link">Liverpool</a>
                    <a href="birkenhead-loft-conversions.html" class="area-link">Birkenhead</a>
                    <a href="wallasey-loft-conversions.html" class="area-link">Wallasey</a>
                    <a href="bootle-loft-conversions.html" class="area-link">Bootle</a>
                    <a href="crosby-loft-conversions.html" class="area-link">Crosby</a>
                    <a href="formby-loft-conversions.html" class="area-link">Formby</a>
                    <a href="southport-loft-conversions.html" class="area-link">Southport</a>
                    <a href="st-helens-loft-conversions.html" class="area-link">St Helens</a>
                </div>
            </div>
            
            <div class="areas-section">
                <h2>🏛️ Leeds & West Yorkshire</h2>
                <div class="areas-grid">
                    <a href="leeds-loft-conversions.html" class="area-link">Leeds</a>
                    <a href="bradford-loft-conversions.html" class="area-link">Bradford</a>
                    <a href="wakefield-loft-conversions.html" class="area-link">Wakefield</a>
                    <a href="huddersfield-loft-conversions.html" class="area-link">Huddersfield</a>
                    <a href="halifax-loft-conversions.html" class="area-link">Halifax</a>
                    <a href="dewsbury-loft-conversions.html" class="area-link">Dewsbury</a>
                    <a href="batley-loft-conversions.html" class="area-link">Batley</a>
                    <a href="keighley-loft-conversions.html" class="area-link">Keighley</a>
                </div>
            </div>
            
            <div class="areas-section">
                <h2>🌳 Cheshire</h2>
                <div class="areas-grid">
                    <a href="chester-loft-conversions.html" class="area-link">Chester</a>
                    <a href="warrington-loft-conversions.html" class="area-link">Warrington</a>
                    <a href="crewe-loft-conversions.html" class="area-link">Crewe</a>
                    <a href="macclesfield-loft-conversions.html" class="area-link">Macclesfield</a>
                    <a href="wilmslow-loft-conversions.html" class="area-link">Wilmslow</a>
                    <a href="knutsford-loft-conversions.html" class="area-link">Knutsford</a>
                    <a href="alderley-edge-loft-conversions.html" class="area-link">Alderley Edge</a>
                    <a href="congleton-loft-conversions.html" class="area-link">Congleton</a>
                </div>
            </div>
            
            <p style="text-align: center; margin-top: 3rem; font-size: 1.1rem;">
                ...and 150+ more locations across the UK. Can't find your area? 
                <a href="/contact" style="color: var(--primary-color); font-weight: 600;">Contact us</a> - we cover all UK locations!
            </p>
        </div>
    </main>
    
    <script>
        function filterAreas() {
            const searchBox = document.getElementById('searchBox');
            const filter = searchBox.value.toLowerCase();
            const areaLinks = document.querySelectorAll('.area-link');
            
            areaLinks.forEach(link => {
                const text = link.textContent.toLowerCase();
                if (text.includes(filter)) {
                    link.style.display = 'flex';
                } else {
                    link.style.display = 'none';
                }
            });
        }
        
        console.log('Loft Conversions Area Index - Building Group - 2025-10-04T19:00:50Z');
    </script>
</body>
</html>
INDEX_FOOTER

echo "✅ Created areas index page: ${output_dir}/index.html"
echo ""
echo "All done! Your loft conversion area pages are ready."
echo ""
echo "Summary:"
echo "--------"
echo "• Generated ${#areas[@]} area-specific loft conversion pages"
echo "• Each page is fully SEO optimized for local searches"
echo "• Created index page at /services/lofts/index.html"
echo "• All pages follow Building Group branding"
echo "• Includes local schema markup for each area"
echo ""
echo "To run this script:"
echo "chmod +x generate-loft-conversion-areas.sh"
echo "./generate-loft-conversion-areas.sh"
