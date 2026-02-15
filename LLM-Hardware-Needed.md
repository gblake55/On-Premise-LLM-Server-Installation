# LLM Hardware Requirements and Build Guide

Complete hardware specification and assembly guide for building a high-performance, cost-effective multi-GPU LLM inference workstation using enterprise-grade components sourced from eBay.

## Table of Contents

- [Overview](#overview)
- [System Specifications](#system-specifications)
- [Complete Parts List](#complete-parts-list)
- [Sourcing Components on eBay](#sourcing-components-on-ebay)
- [Cost Breakdown](#cost-breakdown)
- [Pre-Build Preparation](#pre-build-preparation)
- [Assembly Instructions](#assembly-instructions)
- [BIOS Configuration](#bios-configuration)
- [Power Distribution Strategy](#power-distribution-strategy)
- [Cooling and Thermal Management](#cooling-and-thermal-management)
- [Cable Management](#cable-management)
- [Testing and Validation](#testing-and-validation)
- [Troubleshooting](#troubleshooting)
- [Upgrade Path](#upgrade-path)
- [Additional Resources](#additional-resources)

---

## Overview

This guide provides detailed instructions for building a professional-grade LLM inference workstation optimized for running large language models with multiple GPU configurations. The system leverages enterprise server components purchased used from eBay to provide exceptional performance at a fraction of the cost of new equipment.

**System Highlights:**
- 🖥️ **5 GPUs Total**: 4× RTX 3090 (24GB each) + 1× RTX 5090 (32GB) = 128GB total GPU memory
- 🚀 **AMD EPYC 7443P**: 24 cores / 48 threads unlocked processor
- 💾 **256GB DDR4 RAM**: Massive system memory for large model handling
- 📊 **7× PCIe 4.0 x16 Slots**: ASRock ROMED8-2T motherboard
- ⚡ **3200W Total PSU Power**: Dual 1600W power supplies
- 💿 **4TB NVMe Storage**: High-speed model and cache storage

**Target Use Cases:**
- Large language model inference (Llama 3.1 70B, Mixtral 8x22B, etc.)
- Multi-model serving
- Fine-tuning and training medium-sized models
- Research and development
- Production LLM deployment

**Estimated Total Cost:** $7,000 - $9,000 (used parts from eBay)  
**New Equivalent Cost:** $18,000 - $25,000

---

## System Specifications

| Component | Specification | Purpose |
|-----------|--------------|---------|
| **Motherboard** | ASRock ROMED8-2T | 7× PCIe 4.0 x16 slots for multi-GPU |
| **CPU** | AMD EPYC 7443P (unlocked) | 24C/48T, 2.85GHz base, 4.0GHz boost |
| **CPU Cooler** | Noctua NH-U14S TR4-SP3 or Dynatron A26 | SP3 socket compatible |
| **RAM** | 256GB DDR4-3200 ECC (8× 32GB) | Large model loading and caching |
| **GPU Primary** | 4× NVIDIA RTX 3090 24GB | Main inference workhorses |
| **GPU Secondary** | 1× NVIDIA RTX 5090 32GB | Latest architecture, highest performance |
| **Storage** | 4TB NVMe Gen4 (Samsung 980 Pro or similar) | Models, datasets, cache |
| **PSU** | 2× 1600W 80+ Platinum/Titanium | Dual PSU for 5 GPUs |
| **PCIe Risers** | 5× PCIe 4.0 x16 Riser Cables | Flexible GPU placement |
| **Case** | Open-air mining rig frame | Optimal cooling and accessibility |
| **Monitor** | 24" 1080p or 27" 1440p | System management |
| **Keyboard/Mouse** | Standard USB | Basic I/O |

---

## Complete Parts List

### Required Components

#### 1. Motherboard
**ASRock ROMED8-2T**

**Specifications:**
- Socket: AMD SP3 (EPYC 7001/7002/7003 series)
- PCIe Slots: 7× PCIe 4.0 x16 (full electrical x16)
- Memory: 8× DDR4 DIMM slots, up to 2TB, ECC support
- M.2 Slots: 2× M.2 (PCIe 4.0 x4)
- Network: Dual 10GbE
- Form Factor: EEB (12" × 13")

**eBay Search Terms:**
- "ASRock ROMED8-2T motherboard"
- "ROMED8-2T SP3"
- "ASRock EPYC 7 PCIe motherboard"

**What to Look For:**
- ✅ All PCIe slots intact
- ✅ No bent pins in SP3 socket
- ✅ Includes I/O shield
- ✅ BIOS version 1.40 or higher
- ✅ Seller offers returns

**Expected Price:** $400 - $700 used

---

#### 2. CPU
**AMD EPYC 7443P (Unlocked)**

**Specifications:**
- Cores/Threads: 24C/48T
- Base Clock: 2.85 GHz
- Boost Clock: 4.0 GHz
- Cache: 128MB L3
- TDP: 200W
- Memory Support: DDR4-3200, 8-channel
- PCIe Lanes: 128× PCIe 4.0

**Why This CPU:**
- Unlocked multiplier for overclocking
- Excellent single-thread and multi-thread performance
- 128 PCIe 4.0 lanes (enough for 7 GPUs at full x16)
- Strong price/performance ratio used

**eBay Search Terms:**
- "AMD EPYC 7443P"
- "EPYC 7443P unlocked"
- "7443P Milan processor"

**What to Look For:**
- ✅ OPN: 100-000000340
- ✅ Verify "P" suffix (unlocked)
- ✅ No bent pins
- ✅ Thermal paste not hardened/crusted
- ✅ Comes from reputable seller

**Expected Price:** $800 - $1,200 used

---

#### 3. CPU Cooler
**Noctua NH-U14S TR4-SP3 or Dynatron A26**

**Option 1: Noctua NH-U14S TR4-SP3 (Recommended for quiet operation)**
- Height: 165mm
- Noise: 19.2 - 24.6 dB(A)
- Includes SecuFirm2 SP3 mounting kit
- Premium quality, 6-year warranty

**Option 2: Dynatron A26 (Server-grade, higher airflow)**
- 2U height compatible
- High-static pressure fan
- Designed for EPYC 7003 series
- Louder but better for open-air rigs

**eBay Search Terms:**
- "Noctua NH-U14S TR4-SP3"
- "SP3 CPU cooler EPYC"
- "Dynatron A26"
- "Threadripper SP3 cooler"

**Expected Price:** $60 - $120 used

---

#### 4. Memory
**256GB DDR4 ECC (8× 32GB DIMMs)**

**Specifications:**
- Type: DDR4 ECC RDIMM or LRDIMM
- Speed: 3200MHz (PC4-25600)
- Configuration: 8× 32GB sticks
- Rank: 2Rx4 or 4Rx4
- Voltage: 1.2V

**Recommended Brands:**
- Samsung (M393A4K40DB3-CWE)
- Micron
- SK Hynix
- Kingston Server Premier

**eBay Search Terms:**
- "32GB DDR4 3200 ECC RDIMM"
- "Samsung 32GB DDR4 server memory"
- "DDR4 ECC 3200 EPYC"

**What to Look For:**
- ✅ Match speeds (all 3200MHz)
- ✅ Match types (all RDIMM or all LRDIMM)
- ✅ Same manufacturer (preferred for stability)
- ✅ Tested/working condition

**Expected Price:** $400 - $650 for 256GB set

**Pro Tip:** You can start with 128GB (4× 32GB) and add more later. Populate all 8 channels for best performance (8× 16GB or 8× 32GB).

---

#### 5. Graphics Cards

**Primary GPUs: 4× NVIDIA RTX 3090 (24GB)**

**Specifications:**
- CUDA Cores: 10,496
- Memory: 24GB GDDR6X
- Memory Bandwidth: 936 GB/s
- TDP: 350W
- Power Connectors: 2× 8-pin or 3× 8-pin

**Recommended Models:**
- Founders Edition (best cooling)
- ASUS TUF Gaming
- EVGA FTW3
- MSI Gaming X Trio

**Avoid:**
- Single-fan blower models (poor cooling)
- Cards with obvious physical damage
- Cards used for mining 24/7 (if disclosed)

**eBay Search Terms:**
- "RTX 3090 24GB"
- "NVIDIA RTX 3090 Founders Edition"
- "RTX 3090 ASUS TUF"

**Expected Price:** $650 - $900 each × 4 = $2,600 - $3,600

---

**Secondary GPU: 1× NVIDIA RTX 5090 (32GB)**

**Specifications:**
- CUDA Cores: 21,760
- Memory: 32GB GDDR7
- Memory Bandwidth: 1,792 GB/s
- TDP: 575W
- Power Connectors: 1× 12VHPWR (600W)

**Note:** RTX 5090 is brand new as of 2025, so used prices may not be available yet. Consider new or refurbished.

**Alternatives if RTX 5090 too expensive:**
- RTX 4090 (24GB) - still excellent
- 5th RTX 3090 for uniformity

**eBay Search Terms:**
- "RTX 5090 32GB"
- "NVIDIA GeForce RTX 5090"

**Expected Price:** $1,500 - $2,000 (may need to buy new)

---

#### 6. Storage
**4TB NVMe Gen4 SSD**

**Recommended Models:**
- Samsung 990 Pro 4TB
- WD Black SN850X 4TB
- Crucial T700 4TB
- Seagate FireCuda 530 4TB

**Specifications:**
- Interface: M.2 2280, PCIe 4.0 x4
- Sequential Read: 7,000+ MB/s
- Sequential Write: 6,000+ MB/s
- Endurance: 2,400+ TBW

**eBay Search Terms:**
- "4TB NVMe Gen4"
- "Samsung 990 Pro 4TB"
- "M.2 4TB PCIe 4.0"

**What to Look For:**
- ✅ Check SMART health data
- ✅ Low power-on hours
- ✅ Good endurance remaining (>90%)
- ✅ Includes heatsink or buy separately

**Expected Price:** $200 - $350 used

**Alternative:** Start with 2TB and add second drive later.

---

#### 7. Power Supplies
**2× 1600W 80+ Platinum or Titanium PSUs**

**Why Dual PSU:**
- Total GPU power: ~2,125W (4× 350W + 1× 575W)
- CPU: 200W
- System: ~100W
- Total: ~2,425W
- 2× 1600W = 3,200W capacity (good headroom)

**Recommended Server PSUs:**
- HP 1600W 80+ Platinum (DPS-1600AB A, 750504-001)
- Delta 1600W 80+ Platinum
- Cisco UCSC-PSU2-1600W
- IBM 1600W

**eBay Search Terms:**
- "1600W server PSU platinum"
- "HP 1600W power supply"
- "Dell 1600W PSU"

**What to Look For:**
- ✅ 80+ Platinum or Titanium efficiency
- ✅ Includes breakout board or buy X11 board
- ✅ All cables included
- ✅ Tested working

**Expected Price:** $80 - $150 each × 2 = $160 - $300

**Also Need:**
- 2× X11 or X12 PSU Breakout Boards ($15-30 each)
- PCIe 6-pin to 8-pin cables (for GPUs)
- 24-pin ATX adapter for motherboard

---

#### 8. PCIe Riser Cables
**5× PCIe 4.0 x16 Riser Cables**

**Specifications:**
- Standard: PCIe 4.0
- Length: 30cm - 50cm (depending on case layout)
- Connectors: x16 to x16
- Shielding: Required for PCIe 4.0 speeds

**Recommended Brands:**
- Thermaltake TT Premium PCIe 4.0
- LINKUP Ultra PCIe 4.0
- ASUS ROG Strix Riser Cable

**eBay Search Terms:**
- "PCIe 4.0 riser cable x16"
- "PCIe Gen4 extender 40cm"
- "mining riser cable PCIe 4.0"

**What to Look For:**
- ✅ PCIe 4.0 certified (not 3.0)
- ✅ Proper shielding
- ✅ Correct length for your frame
- ✅ Angled connectors (helpful for tight spaces)

**Expected Price:** $25 - $50 each × 5 = $125 - $250

**Note:** You can mount 2 GPUs directly on motherboard and use 3 risers to save cost.

---

#### 9. Open-Air Mining Rig Frame
**8-GPU Compatible Frame**

**Specifications:**
- Material: Steel or aluminum
- GPU Capacity: 8-12 GPUs
- Dimensions: ~90cm × 45cm × 45cm
- Includes: GPU mounting brackets, PSU mounting

**Recommended Features:**
- Adjustable GPU spacing
- Sturdy construction (steel preferred)
- Stackable design
- Cable management provisions

**eBay Search Terms:**
- "8 GPU mining rig frame"
- "open air mining case 12 GPU"
- "cryptocurrency mining frame"
- "GPU rig chassis steel"

**What to Look For:**
- ✅ Heavy-duty construction
- ✅ All mounting hardware included
- ✅ Motherboard mounting tray
- ✅ PSU mounting brackets (for 2 PSUs)

**Expected Price:** $80 - $150 used

**Alternative:** Build your own with aluminum extrusion.

---

#### 10. Monitor, Keyboard, Mouse

**Monitor:**
- 24" 1080p or 27" 1440p
- IPS panel preferred
- HDMI or DisplayPort input
- **Expected Price:** $80 - $150 used

**Keyboard:**
- Standard USB keyboard
- Mechanical or membrane
- **Expected Price:** $15 - $40 used

**Mouse:**
- USB wired or wireless
- Basic optical mouse sufficient
- **Expected Price:** $10 - $25 used

**eBay Search Terms:**
- "24 inch monitor 1080p"
- "Dell monitor P2419H"
- "USB keyboard"
- "Logitech wireless mouse"

---

### Additional Required Components

#### 11. Thermal Paste
**High-Performance Thermal Compound**

- Noctua NT-H1 or NT-H2
- Thermal Grizzly Kryonaut
- Arctic MX-5

**Expected Price:** $8 - $15

---

#### 12. Additional Fans
**Case Fans for GPU Cooling**

**Recommended:**
- 3-5× 120mm or 140mm fans
- High static pressure fans
- PWM control preferred

**Models:**
- Noctua NF-P12 redux
- Arctic P12 PWM
- be quiet! Pure Wings 2

**Expected Price:** $10 - $20 each × 3-5 = $30 - $100

---

#### 13. Power Distribution
**PSU Breakout Boards and Cables**

**Required:**
- 2× X11/X12 Server PSU Breakout Boards
- ATX 24-pin adapter
- Multiple PCIe 8-pin cables
- SATA power cables

**Expected Price:** $50 - $100 total

---

#### 14. Cable Ties and Management
**Organization Supplies**

- 100pk Velcro cable ties
- Zip ties (various sizes)
- Cable sleeves (optional)
- Label maker or labels

**Expected Price:** $15 - $30

---

#### 15. Anti-Static Wrist Strap
**ESD Protection**

Essential for handling components safely.

**Expected Price:** $5 - $10

---

#### 16. Toolkit
**Screwdriver Set**

- Phillips #1 and #2
- Magnetic tip preferred
- Hex drivers (if needed)

**Expected Price:** $15 - $30

---

## Sourcing Components on eBay

### General eBay Shopping Tips

**1. Search Strategies:**
```
Use multiple search terms:
- "ASRock ROMED8-2T" + "SP3"
- "RTX 3090" + "ASUS" + "working"
- "EPYC 7443P" + "unlocked"

Set alerts for new listings
Use "Sold Listings" to gauge market price
```

**2. Seller Evaluation:**
- ✅ 98%+ positive feedback
- ✅ >100 transactions
- ✅ Returns accepted (14-30 days)
- ✅ "Top Rated Seller" badge
- ✅ Detailed photos of actual item
- ✅ Clear description of condition

**3. Listing Red Flags:**
- ❌ Stock photos only
- ❌ Vague description ("untested", "as-is")
- ❌ New seller with expensive items
- ❌ No returns accepted
- ❌ Suspiciously low price

**4. Best Offers:**
- Most sellers accept 10-15% off asking price
- Start at 20% below asking
- Be polite and reasonable
- Bundle multiple items for better deals

**5. Timing:**
- Best deals: Tuesday-Thursday evenings
- Avoid: Weekend bidding wars
- End of month: Sellers more motivated

---

### Component-Specific Sourcing

#### Motherboard (ROMED8-2T)
**Questions to Ask Seller:**
- "Has this been tested? What CPU/RAM?"
- "Are all PCIe slots working?"
- "What BIOS version is installed?"
- "Any included accessories (SATA cables, etc.)?"

**Test Before Purchase:**
Request seller to test with CPU if possible.

---

#### CPU (EPYC 7443P)
**Questions to Ask Seller:**
- "What was this CPU used for?"
- "How many hours of runtime?"
- "Was it overclocked?"
- "Confirm OPN: 100-000000340"

**Verification:**
OPN marking on CPU IHS should read 100-000000340.

---

#### GPUs (RTX 3090/5090)
**Questions to Ask Seller:**
- "Was this used for mining?"
- "What are the temps under load?"
- "Any coil whine or artifacts?"
- "Will you provide GPU-Z screenshot?"

**Red Flags:**
- Mining operation sales (24/7 usage)
- Repasted recently (may indicate overheating issues)
- Missing backplate or shroud

---

#### Memory (256GB DDR4 ECC)
**Questions to Ask Seller:**
- "Has this been tested with MemTest86?"
- "Any errors in BIOS detection?"
- "What server/motherboard was this used in?"

**Tip:** Buy all from same seller if possible for matched set.

---

## Cost Breakdown

### Detailed Budget (Used Parts from eBay)

| Component | Quantity | Unit Price | Total |
|-----------|----------|------------|-------|
| ASRock ROMED8-2T | 1 | $400-700 | $550 |
| AMD EPYC 7443P | 1 | $800-1,200 | $1,000 |
| SP3 CPU Cooler | 1 | $60-120 | $90 |
| 32GB DDR4 ECC | 8 | $50-80 | $560 |
| RTX 3090 24GB | 4 | $650-900 | $3,000 |
| RTX 5090 32GB | 1 | $1,500-2,000 | $1,750 |
| 4TB NVMe Gen4 | 1 | $200-350 | $275 |
| 1600W PSU | 2 | $80-150 | $240 |
| PCIe 4.0 Riser | 5 | $25-50 | $175 |
| Mining Rig Frame | 1 | $80-150 | $115 |
| Monitor 24" | 1 | $80-150 | $115 |
| Keyboard | 1 | $15-40 | $25 |
| Mouse | 1 | $10-25 | $15 |
| PSU Breakout Boards | 2 | $15-30 | $45 |
| Case Fans | 4 | $10-20 | $60 |
| Thermal Paste | 1 | $8-15 | $12 |
| Cables/Accessories | - | - | $75 |
| **TOTAL** | | | **$8,102** |

**Budget Range:** $7,000 - $9,000 depending on deals

**Cost Savings vs New:** ~$12,000 - $16,000

---

## Pre-Build Preparation

### 1. Workspace Setup

**Requirements:**
- Large work surface (6ft × 3ft minimum)
- Good lighting (overhead + task light)
- Anti-static mat (or cardboard)
- Organize parts by category

**Checklist:**
- [ ] Clear, clean workspace
- [ ] Anti-static protection
- [ ] Tools laid out
- [ ] All parts unboxed and verified
- [ ] Assembly instructions printed

---

### 2. Inventory Check

**Verify you have:**
- [ ] Motherboard with I/O shield
- [ ] CPU with no bent pins
- [ ] CPU cooler with mounting hardware
- [ ] All 8 RAM sticks
- [ ] All 5 GPUs
- [ ] NVMe drive
- [ ] 2× PSUs with cables
- [ ] 5× PCIe risers
- [ ] Mining frame with all brackets
- [ ] Monitor, keyboard, mouse
- [ ] Thermal paste
- [ ] Cable ties
- [ ] Screwdriver set

---

### 3. Component Testing (Optional but Recommended)

**Motherboard + CPU + RAM Test:**
Before full assembly, test core components:

1. Place motherboard on anti-static surface
2. Install CPU and cooler
3. Install 1 stick of RAM in slot A1
4. Connect PSU (24-pin + 8-pin CPU)
5. Connect monitor to onboard video (if available) or install 1 GPU
6. Power on and enter BIOS
7. Verify CPU and RAM detected
8. Power off and proceed with full build

---

## Assembly Instructions

### Step 1: Assemble Mining Rig Frame

**Time Required:** 30-45 minutes

1. **Lay out all frame parts**
   - Base rails
   - Vertical supports
   - GPU mounting bars
   - Motherboard tray
   - PSU brackets

2. **Assemble base frame**
   - Connect base rails with vertical supports
   - Use provided bolts/screws
   - Ensure frame is square and level

3. **Install motherboard tray**
   - Mount tray to frame
   - Position for cable access from bottom
   - Leave space for PSU(s) below

4. **Install GPU mounting bars**
   - Space bars 2-3 slots apart (depends on GPU thickness)
   - Allow 40-50mm between GPUs for airflow
   - Position for riser cable routing

5. **Install PSU mounting brackets**
   - Bottom of frame or rear mounting
   - Ensure both PSUs fit
   - Fan orientation: intake from outside

6. **Verify stability**
   - Frame should not wobble
   - All connections tight
   - Ready for component installation

---

### Step 2: Install CPU and Cooler on Motherboard

**Time Required:** 20-30 minutes

**⚠️ CRITICAL: Use anti-static protection throughout!**

1. **Place motherboard on anti-static surface**
   - Use motherboard box or anti-static mat
   - Ensure good lighting

2. **Install CPU**
   ```
   SP3 Socket Installation:
   a. Lift CPU socket lever (may require significant force)
   b. Remove protective cover
   c. Align CPU triangle marker with socket triangle
   d. Gently place CPU - DO NOT FORCE
   e. CPU should drop into place with no pressure
   f. Close socket lever (requires firm pressure)
   g. Verify CPU is flush and secure
   ```

3. **Apply thermal paste**
   - Clean CPU IHS with isopropyl alcohol
   - Apply pea-sized dot in center
   - Or use spread method for large EPYC die

4. **Install CPU cooler**
   ```
   For Noctua NH-U14S TR4-SP3:
   a. Install backplate on rear of motherboard
   b. Align mounting brackets over CPU
   c. Attach retention clips
   d. Lower heatsink onto CPU
   e. Secure with spring-loaded screws
   f. Tighten in cross pattern (don't over-tighten)
   g. Connect fan to CPU_FAN header
   ```

5. **Verify installation**
   - Cooler is firmly mounted
   - No gaps between heatsink and CPU
   - Fan spins freely
   - Fan cable routed cleanly

---

### Step 3: Install Memory

**Time Required:** 10-15 minutes

**ROMED8-2T Memory Configuration:**
- 8× DIMM slots (4 channels × 2 DIMMs)
- Channels: A, B, C, D
- Slots per channel: 1, 2

**Population Order for 8× 32GB:**
```
Install in this order for 8-channel operation:
1. A1 (furthest from CPU)
2. B1
3. C1
4. D1
5. A2
6. B2
7. C2
8. D2
```

**Installation Procedure:**
1. Open DIMM slot latches
2. Align DIMM notch with slot key
3. Press down firmly until latches click (requires force)
4. Verify both latches are locked
5. Repeat for all 8 DIMMs

**Pro Tip:** Install in pairs (A1+A2, B1+B2, etc.) for better organization.

---

### Step 4: Install NVMe Drive

**Time Required:** 5 minutes

**ROMED8-2T has 2× M.2 slots:**
- M.2_1: Near CPU (primary)
- M.2_2: Near bottom (secondary)

**Installation:**
1. Locate M.2_1 slot (check motherboard manual)
2. Remove retention screw
3. Insert NVMe drive at 30° angle
4. Press down gently
5. Secure with retention screw
6. Install heatsink if included

---

### Step 5: Mount Motherboard in Frame

**Time Required:** 15-20 minutes

1. **Install I/O shield**
   - Snap I/O shield into motherboard tray
   - Ensure tight fit
   - Metal tabs face inward

2. **Position motherboard standoffs**
   - ROMED8-2T is EEB (12" × 13")
   - Install standoffs in all matching holes
   - Typically 9-10 standoffs for EEB

3. **Place motherboard on standoffs**
   - Align with I/O shield
   - Line up standoff holes
   - DO NOT force

4. **Secure motherboard**
   - Install screws in cross pattern
   - Finger-tight first, then snug
   - Don't over-tighten (risk of cracking)

5. **Verify installation**
   - Motherboard is level
   - No flex when pressing on corners
   - I/O ports align with shield

---

### Step 6: Install Power Supplies

**Time Required:** 20 minutes

1. **Mount first PSU (PSU1 - Motherboard/CPU)**
   - Position fan facing outward for intake
   - Secure with mounting screws
   - Route cables toward motherboard

2. **Mount second PSU (PSU2 - GPUs)**
   - Position next to PSU1
   - Same fan orientation
   - Route cables toward GPU area

3. **Install PSU breakout boards**
   - Connect to 12V output on server PSUs
   - Secure breakout boards to frame
   - Label: "PSU1 - MOBO" and "PSU2 - GPU"

4. **Cable preparation**
   - Organize cables by function
   - Don't connect to motherboard yet
   - Keep extra cables bundled

---

### Step 7: Connect Power to Motherboard

**Time Required:** 10 minutes

**PSU1 Connections (Motherboard PSU):**

1. **24-pin ATX power**
   - Locate ATX_PWR1 on motherboard
   - Connect 24-pin from PSU breakout
   - Ensure latch clicks

2. **8-pin CPU power (×2)**
   - ROMED8-2T requires 2× 8-pin CPU power
   - Locate CPU_PWR1 and CPU_PWR2 near CPU socket
   - Connect both 8-pin EPS connectors
   - Essential for high CPU power delivery

3. **SATA/Peripheral power**
   - Connect to NVMe heatsink fan (if applicable)
   - Reserve for additional drives later

**Verify all connections are secure before proceeding.**

---

### Step 8: Install GPUs

**Time Required:** 45-60 minutes

**GPU Installation Strategy:**

**Direct PCIe Slots (No Riser):**
- GPU 1: PCIe Slot 1 (closest to CPU) - RTX 5090
- GPU 2: PCIe Slot 3 (skip slot 2 for spacing) - RTX 3090

**With PCIe Risers:**
- GPU 3: Riser to Slot 4 - RTX 3090
- GPU 4: Riser to Slot 5 - RTX 3090
- GPU 5: Riser to Slot 6 - RTX 3090

**Installation Procedure:**

**For Direct PCIe Installation:**
1. Remove PCIe slot covers from motherboard I/O area
2. Align GPU with PCIe slot
3. Press down firmly until click
4. Secure GPU bracket with screw
5. Leave power cables disconnected for now

**For Riser Installation:**
1. Connect riser to PCIe slot on motherboard
2. Mount GPU on frame's GPU bars
3. Connect riser to GPU
4. Secure GPU to mounting bar
5. Ensure riser cable not twisted or kinked

**GPU Spacing:**
- Maintain 40-50mm between GPUs
- Avoid blocking fan intakes
- Stagger heights if needed for airflow

---

### Step 9: Power GPU Connections

**Time Required:** 30 minutes

**PSU2 Dedicated to GPUs:**

**Power Requirements:**
- RTX 5090: 600W (1× 12VHPWR connector)
- RTX 3090: 350W each (2× 8-pin or 3× 8-pin per GPU)

**Connection Strategy:**

**Option A: Server PSU with Breakout Board**
```
X12 Breakout Board provides:
- Multiple PCIe 8-pin outputs
- Direct 12V power

Connect:
GPU1 (RTX 5090): Use 12VHPWR adapter or 3× 8-pin to 12VHPWR
GPU2 (RTX 3090): 2× 8-pin PCIe
GPU3 (RTX 3090): 2× 8-pin PCIe
GPU4 (RTX 3090): 2× 8-pin PCIe
GPU5 (RTX 3090): 2× 8-pin PCIe
```

**Load Balancing:**
```
PSU1 (1600W): Motherboard (150W) + CPU (200W) = 350W used
PSU2 (1600W): 5 GPUs (2125W total) - OVERLOAD!

SOLUTION: Split GPU power across both PSUs
PSU1: RTX 5090 (600W) + 1× RTX 3090 (350W) = 950W + overhead
PSU2: 3× RTX 3090 (1050W)
```

**Revised Connection:**
```
PSU1 (After mobo/CPU):
- GPU1: RTX 5090 (3× 8-pin or 12VHPWR)
- GPU2: RTX 3090 (2× 8-pin)

PSU2:
- GPU3: RTX 3090 (2× 8-pin)
- GPU4: RTX 3090 (2× 8-pin)  
- GPU5: RTX 3090 (2× 8-pin)
```

**Cable Management:**
- Use separate PCIe cables per GPU (don't daisy-chain)
- Route cables cleanly
- Label each GPU and its power source
- Secure with velcro ties

---

### Step 10: Install Additional Fans

**Time Required:** 15 minutes

**Fan Placement Strategy:**
1. **Front fans (intake):** 2× 120mm or 140mm
   - Push cool air toward GPUs
   - Low-medium speed

2. **Rear fans (exhaust):** 2× 120mm
   - Pull hot air away from GPUs
   - Medium-high speed

3. **Side fans (optional):** 1× 140mm
   - Direct airflow between GPU rows

**Fan Connections:**
- Connect to motherboard fan headers
- Or use PSU SATA to 4-pin adapters
- Set to 40-60% speed initially

**Airflow Direction:**
- Front to back
- Bottom to top
- Create positive pressure (more intake than exhaust)

---

### Step 11: Cable Management

**Time Required:** 30 minutes

**Organize cables by type:**

1. **Power cables:**
   - Route along frame edges
   - Use cable ties every 6-8 inches
   - Keep away from fans

2. **PCIe risers:**
   - Avoid sharp bends (>90°)
   - Secure to prevent sagging
   - Don't cross power cables if possible

3. **Front panel connections:**
   - Power button
   - Power LED
   - HDD LED
   - USB headers (if needed)

4. **Label everything:**
   - GPU numbers (GPU1-GPU5)
   - PSU assignments
   - Fan connections

**Pro Tips:**
- Use velcro ties (reusable)
- Leave slack for maintenance
- Take photos for reference

---

### Step 12: Connect Peripherals

**Time Required:** 5 minutes

1. **Monitor:**
   - Connect to RTX 5090 DisplayPort/HDMI
   - Use GPU1 for primary display

2. **Keyboard and Mouse:**
   - USB 2.0 or 3.0 ports on rear I/O

3. **Network:**
   - Connect Ethernet to onboard 10GbE (optional)
   - Or use Wi-Fi if installing card later

---

### Step 13: Pre-Power-On Checklist

**Time Required:** 15 minutes

**⚠️ CRITICAL: Verify before first power-on!**

**Motherboard:**
- [ ] CPU installed correctly
- [ ] Cooler mounted securely
- [ ] All 8 RAM sticks installed
- [ ] 24-pin ATX power connected
- [ ] 2× 8-pin CPU power connected
- [ ] NVMe drive installed

**GPUs:**
- [ ] All 5 GPUs seated properly
- [ ] All GPUs have power connected
- [ ] Risers connected firmly
- [ ] No loose cables near fans

**Power Supplies:**
- [ ] Both PSUs plugged in
- [ ] PSU switches OFF
- [ ] All cables connected
- [ ] No short circuits visible

**Cooling:**
- [ ] CPU fan connected
- [ ] Case fans connected
- [ ] All fans spin freely
- [ ] No obstructions

**Peripherals:**
- [ ] Monitor connected to GPU1
- [ ] Keyboard connected
- [ ] Mouse connected

**Safety:**
- [ ] No loose screws in system
- [ ] No metal touching motherboard
- [ ] Cable management complete
- [ ] Frame stable and level

---

### Step 14: First Power-On

**Time Required:** 10 minutes

**Procedure:**

1. **Turn on PSU switches**
   - PSU1 first (motherboard)
   - PSU2 second (GPUs)
   - Wait 5 seconds

2. **Press power button**
   - Short press
   - Watch for:
     - CPU fan spinning
     - GPU fans spinning
     - Monitor signal
     - POST beep (if speaker installed)

3. **Expected behavior:**
   - Fans start spinning
   - LEDs light up
   - Monitor shows BIOS splash screen
   - System may reboot once (training memory)

4. **If no display:**
   - Wait 60-90 seconds (EPYC POST is slow)
   - Check debug LEDs on motherboard
   - Verify monitor input source
   - Reseat GPU if needed

5. **If successful:**
   - Proceed to BIOS configuration
   - Do not install OS yet

---

## BIOS Configuration

### Initial BIOS Setup

**Time Required:** 20-30 minutes

**Access BIOS:**
- Press `DEL` or `F2` during POST
- May take 60+ seconds to appear on first boot

---

### Step 1: Load Defaults

1. Press F9 or find "Load Optimized Defaults"
2. Select "Yes"
3. Press F10 to save and reboot

---

### Step 2: Update BIOS (Recommended)

1. Download latest BIOS from ASRock website
2. Copy to USB drive (FAT32)
3. Enter BIOS
4. Go to "Tool" → "Instant Flash"
5. Select BIOS file
6. Follow prompts (do NOT power off)
7. Reboot after completion

**Current recommended version:** 2.10 or higher

---

### Step 3: Configure Memory

**Location:** Advanced → AMD CBS → UMC Common Options

1. **Enable XMP/DOCP:**
   - AMD CBS → NBIO Common Options
   - Memory Clock Speed: 3200MHz
   - Or use "Auto" for auto-detection

2. **Verify memory configuration:**
   - Main screen shows: 256GB DDR4-3200
   - All 8 channels populated

---

### Step 4: Configure PCIe

**Location:** Advanced → PCI Subsystem Settings

1. **PCIe Speed:**
   - Set to "Gen4" or "Auto"
   - Enables PCIe 4.0 for GPUs

2. **Above 4G Decoding:**
   - Enable: Yes
   - Required for multiple GPUs

3. **Re-Size BAR Support:**
   - Enable: Yes
   - Improves GPU performance

4. **SR-IOV Support:**
   - Auto or Disabled (not needed for LLM use)

---

### Step 5: Configure Boot

**Location:** Boot Menu

1. **Boot Mode:**
   - UEFI only (disable Legacy)

2. **Boot Priority:**
   - Set NVMe drive as first boot device

3. **Fast Boot:**
   - Disabled (easier troubleshooting)

---

### Step 6: Configure CPU (Optional)

**Location:** Advanced → AMD CBS → CPU Common Options

**For stock operation:**
- Leave all at Auto

**For overclocking (advanced):**
- Adjust Core Frequency
- Adjust voltage (carefully!)
- Monitor temperatures

---

### Step 7: Configure Fans

**Location:** Monitor → Fan Settings

1. **CPU Fan:**
   - Mode: PWM or DC (match your cooler)
   - Profile: Performance or Silent
   - Target temp: 70°C

2. **Chassis Fans:**
   - Mode: PWM or DC
   - Speed: 40-60%
   - Increase if GPU temps high

---

### Step 8: Verify All Components

**Location:** Main BIOS Screen

**Verify detected:**
- [ ] CPU: AMD EPYC 7443P, 24C/48T
- [ ] Memory: 256GB DDR4-3200
- [ ] NVMe: 4TB drive detected
- [ ] All 5 GPUs in PCIe Configuration page

**Check PCIe Configuration:**
- Advanced → Chipset Configuration → PCIe Configuration
- Should show 5 GPUs in slots
- Each running at PCIe 4.0 x16 or x8

---

### Step 9: Save and Exit

1. Press F10
2. Select "Save Changes and Reset"
3. System will reboot

---

## Power Distribution Strategy

### Detailed Power Analysis

**Component Power Draw:**

| Component | Power Draw | Notes |
|-----------|------------|-------|
| EPYC 7443P | 200W | TDP, can spike to 240W |
| Motherboard | 50W | Chipset, fans, peripherals |
| 256GB DDR4 | 80W | ~10W per 32GB stick |
| NVMe 4TB | 10W | Peak during writes |
| RTX 5090 | 575W | TDP, can spike to 600W+ |
| RTX 3090 #1 | 350W | TDP per card |
| RTX 3090 #2 | 350W | TDP per card |
| RTX 3090 #3 | 350W | TDP per card |
| RTX 3090 #4 | 350W | TDP per card |
| Case Fans (4×) | 20W | ~5W each |
| **TOTAL** | **2,335W** | Peak power draw |

---

### Power Supply Load Distribution

**PSU1 (1600W) - Primary System:**
- 24-pin ATX: Motherboard (50W)
- 2× 8-pin EPS: CPU (200W)
- SATA: NVMe, Fans (30W)
- PCIe: RTX 5090 (600W)
- PCIe: RTX 3090 #1 (350W)
- **Total: 1,230W (77% load)**

**PSU2 (1600W) - GPUs:**
- PCIe: RTX 3090 #2 (350W)
- PCIe: RTX 3090 #3 (350W)
- PCIe: RTX 3090 #4 (350W)
- **Total: 1,050W (66% load)**

**Efficiency Sweet Spot:** Both PSUs running at 65-80% load (optimal for 80+ Platinum)

---

### Power Sequencing

**Startup:**
1. Turn on PSU2 (GPUs) first
2. Wait 3 seconds
3. Turn on PSU1 (motherboard)
4. Press power button

**Shutdown:**
1. OS shutdown command
2. Wait for complete power down
3. Turn off PSU1
4. Turn off PSU2

**Why this order:**
- Prevents motherboard from trying to power GPUs during boot
- Reduces inrush current to motherboard
- Extends PSU lifespan

---

### Surge Protection

**Recommended:**
- Use 2× separate surge protectors (1 per PSU)
- Or 1× high-capacity UPS (2000VA+)
- Avoid daisy-chaining power strips

**UPS Recommendations:**
- APC Smart-UPS 2200VA
- CyberPower CP1500PFCLCD
- Tripp Lite SMART3000RM2U

---

## Cooling and Thermal Management

### Temperature Targets

**Component:** | **Idle** | **Load** | **Max Safe** |
|-------------|----------|----------|--------------|
| EPYC 7443P | 35-45°C | 60-75°C | 95°C |
| RTX 5090 | 30-40°C | 70-80°C | 90°C |
| RTX 3090 | 30-40°C | 75-85°C | 93°C |
| Memory | 35-45°C | 50-60°C | 85°C |
| NVMe SSD | 35-45°C | 60-70°C | 85°C |

---

### Airflow Optimization

**Ideal Setup:**
```
[Front Intake Fans] → [GPUs] → [Rear Exhaust Fans]
         ↑                            ↑
    Cool Air                     Hot Air
```

**Fan Configuration:**
- Front: 2× 140mm intake @ 800-1000 RPM
- Rear: 2× 120mm exhaust @ 1000-1200 RPM
- Side: 1× 140mm intake (between GPUs)

---

### GPU Cooling Considerations

**GPU Spacing:**
- Minimum 40mm between GPUs
- Stagger heights if possible
- Direct cool air flow between cards

**GPU Fan Curves (Adjust in NVIDIA Control Panel):**
```
30°C: 30% fan speed
50°C: 40% fan speed
60°C: 50% fan speed
70°C: 65% fan speed
80°C: 85% fan speed
85°C: 100% fan speed
```

---

### Thermal Monitoring

**Software:**
- `nvidia-smi` - GPU temps
- `sensors` - CPU and motherboard temps
- `nvitop` - Real-time GPU monitoring
- `btop` - System-wide monitoring

**Automated monitoring script:**
```bash
#!/bin/bash
while true; do
  echo "=== $(date) ==="
  echo "CPU Temp: $(sensors | grep Tctl | awk '{print $2}')"
  nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
  sleep 60
done
```

---

## Cable Management

### Cable Organization Strategy

**Color Coding (Optional but Helpful):**
- Red: PSU1 power cables
- Blue: PSU2 power cables
- Yellow: PCIe risers
- Black: Data cables (SATA, USB)

**Routing Paths:**
1. **Power cables:** Along frame bottom and sides
2. **PCIe risers:** Direct paths, no crossing
3. **Fan cables:** Along vertical supports

**Securing Methods:**
- Velcro ties: Every 6-8 inches
- Zip ties: Permanent locations only
- Cable clips: Attach to frame

---

## Testing and Validation

### Post-Assembly Testing

**Time Required:** 1-2 hours

---

### Test 1: BIOS POST

**✓ Pass Criteria:**
- System boots to BIOS
- All components detected
- No error beeps

**If Failed:**
- Check all power connections
- Reseat RAM
- Remove all GPUs except one, test

---

### Test 2: Memory Test

**Run MemTest86:**
1. Download from memtest86.com
2. Create bootable USB
3. Boot from USB
4. Run full test (4-8 hours)
5. 0 errors = PASS

---

### Test 3: CPU Stress Test

**After OS installation:**
```bash
# Install stress-ng
sudo dnf install stress-ng

# Run CPU stress test
stress-ng --cpu 48 --timeout 300s --metrics

# Monitor temps
watch -n 1 sensors
```

**✓ Pass Criteria:**
- CPU temp < 85°C under load
- No throttling
- System stable for 5 minutes

---

### Test 4: GPU Detection

**Verify all GPUs detected:**
```bash
nvidia-smi -L
```

**Expected output:**
```
GPU 0: NVIDIA GeForce RTX 5090
GPU 1: NVIDIA GeForce RTX 3090
GPU 2: NVIDIA GeForce RTX 3090
GPU 3: NVIDIA GeForce RTX 3090
GPU 4: NVIDIA GeForce RTX 3090
```

---

### Test 5: GPU Stress Test

**Run on each GPU individually:**
```bash
# GPU 0
nvidia-smi -i 0
# Note idle temp

# Install CUDA samples or use gpu-burn
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make
./gpu_burn 300  # 5 minute burn test

# Monitor temps
watch -n 1 nvidia-smi
```

**✓ Pass Criteria:**
- GPU temp < 85°C
- No artifacts or crashes
- Fans functioning

**Repeat for all 5 GPUs**

---

### Test 6: Multi-GPU Stress

**Test all GPUs simultaneously:**
```bash
# Run gpu-burn on all GPUs
./gpu_burn -d 0,1,2,3,4 300

# Or use nvidia-smi dmon
nvidia-smi dmon -s pucvmet -d 1
```

**✓ Pass Criteria:**
- All GPUs stable
- PSUs handling load
- No power cycling
- Temps acceptable

---

### Test 7: Storage Performance

**Test NVMe speed:**
```bash
# Install fio
sudo dnf install fio

# Sequential read test
fio --name=seqread --rw=read --bs=1M --size=10G --numjobs=1 --runtime=60

# Sequential write test
fio --name=seqwrite --rw=write --bs=1M --size=10G --numjobs=1 --runtime=60
```

**✓ Pass Criteria:**
- Read: >5,000 MB/s
- Write: >4,000 MB/s

---

### Test 8: Network (If Configured)

**Test 10GbE:**
```bash
# Install iperf3
sudo dnf install iperf3

# Server on one machine
iperf3 -s

# Client on this machine
iperf3 -c <server-ip>
```

**✓ Pass Criteria:**
- Throughput: >9 Gbps
- No packet loss

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: System Won't POST

**Symptoms:**
- No display
- No beeps
- Fans spin but nothing happens

**Solutions:**
1. **Clear CMOS**
   - Remove CMOS battery for 30 seconds
   - Or use CMOS clear jumper
   - Reboot

2. **Breadboard test**
   - Remove all GPUs
   - Keep only 1 stick of RAM
   - Test outside of case
   - Add components back one at a time

3. **Check power**
   - Verify 24-pin ATX seated
   - Verify both 8-pin CPU power connected
   - Try different PSU

---

#### Issue: Memory Not Detected

**Symptoms:**
- BIOS shows less than 256GB
- Beep codes
- Memory training fails

**Solutions:**
1. **Reseat all DIMMs**
   - Remove and reinstall firmly
   - Ensure latches click

2. **Test individually**
   - Install one DIMM in slot A1
   - Boot and test
   - Mark working DIMMs

3. **Update BIOS**
   - Newer BIOS may improve compatibility

4. **Check compatibility**
   - Verify DIMMs are ECC RDIMM
   - All same speed (3200MHz)

---

#### Issue: GPU Not Detected

**Symptoms:**
- nvidia-smi shows fewer than 5 GPUs
- PCIe errors in BIOS

**Solutions:**
1. **Reseat GPU**
   - Remove and reinstall
   - Check PCIe latch

2. **Test direct vs riser**
   - Remove riser, test GPU directly
   - Replace faulty riser

3. **Check power**
   - Verify all PCIe power connected
   - Try different PSU cables

4. **BIOS settings**
   - Enable "Above 4G Decoding"
   - Enable "Re-Size BAR"
   - PCIe Gen set to Auto or Gen4

---

#### Issue: High GPU Temperatures

**Symptoms:**
- GPUs exceed 85°C under load
- Thermal throttling

**Solutions:**
1. **Improve airflow**
   - Add intake fans
   - Increase fan speed
   - Space GPUs further apart

2. **Check thermal paste**
   - May need repaste (for used GPUs)
   - Use quality paste (Thermal Grizzly)

3. **Reduce power limit**
   ```bash
   nvidia-smi -i 0 -pl 300  # Limit to 300W
   ```

4. **Undervolt GPU**
   - Use MSI Afterburner
   - Reduce voltage by 50-100mV

---

#### Issue: System Crashes Under Load

**Symptoms:**
- Random reboots during inference
- Power cycles
- Black screen crashes

**Solutions:**
1. **PSU issue**
   - Check PSU capacity
   - Verify all power cables
   - Try balancing load differently

2. **Memory error**
   - Run MemTest86
   - Replace faulty DIMMs

3. **GPU driver**
   - Update to latest NVIDIA driver
   - Try different driver version

4. **Overheating**
   - Monitor temps during crash
   - Improve cooling

---

#### Issue: PCIe Riser Problems

**Symptoms:**
- GPU not detected on riser
- Instability with risers
- Lower performance

**Solutions:**
1. **Check riser quality**
   - Use PCIe 4.0 rated risers
   - Replace cheap risers

2. **Reduce PCIe speed**
   - BIOS: Set to Gen3 instead of Gen4
   - Improves stability with lower-quality risers

3. **Shorter risers**
   - Use shortest risers possible
   - 30cm max for stability

---

## Upgrade Path

### Future Upgrade Options

**Short Term (1 year):**
- [ ] Add second 4TB NVMe drive
- [ ] Upgrade to 512GB RAM (requires 8× 64GB DIMMs)
- [ ] Add 10GbE network card (if not using onboard)

**Medium Term (2-3 years):**
- [ ] Replace RTX 3090s with newer generation
- [ ] Upgrade to faster NVMe (PCIe 5.0)
- [ ] Add more powerful CPU cooler for overclocking

**Long Term (3-5 years):**
- [ ] Upgrade to newer EPYC CPU (7004/7005 series)
- [ ] Replace all GPUs with latest generation
- [ ] Add redundant NVMe drives (RAID configuration)

---

### Compatibility Notes

**CPU Compatibility:**
- ROMED8-2T supports EPYC 7001/7002/7003
- BIOS update required for 7003 series (Milan)
- Consider EPYC 7543P (32-core) or 7643 (48-core) upgrades

**RAM Compatibility:**
- Max: 2TB (8× 256GB LRDIMMs)
- Upgrade to 512GB: Use 8× 64GB RDIMMs
- Must be DDR4 ECC RDIMM or LRDIMM

**GPU Compatibility:**
- Any PCIe GPU will work
- Consider future RTX 6000 series
- Professional GPUs (A6000, H100) also supported

---

## Additional Resources

### Useful Links

**Motherboard:**
- [ASRock ROMED8-2T Product Page](https://www.asrock.com/server/amd/romed8-2t/)
- [ROMED8-2T Manual](https://www.asrock.com/support/index.asp?cat=Manual)
- [Latest BIOS Downloads](https://www.asrock.com/support/download.asp?Model=ROMED8-2T)

**CPU:**
- [AMD EPYC 7443P Specifications](https://www.amd.com/en/products/cpu/amd-epyc-7443p)
- [EPYC Overclocking Guide](https://www.overclock.net/threads/epyc-overclocking.1783357/)

**GPU:**
- [NVIDIA RTX 3090 Specs](https://www.nvidia.com/en-us/geforce/graphics-cards/30-series/rtx-3090-3090ti/)
- [NVIDIA RTX 5090 Specs](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/)
- [vLLM Supported GPUs](https://docs.vllm.ai/en/latest/getting_started/installation.html)

**Communities:**
- [r/homelab](https://reddit.com/r/homelab) - Home server builds
- [ServeTheHome Forums](https://forums.servethehome.com/) - Enterprise hardware
- [r/LocalLLaMA](https://reddit.com/r/LocalLLaMA) - Local LLM running
- [Level1Techs Forum](https://forum.level1techs.com/) - High-end builds

**Guides:**
- [EPYC Server Build Guide](https://www.servethehome.com/amd-epyc-7003-milan-review/)
- [Multi-GPU Deep Learning Setup](https://timdettmers.com/2018/12/16/deep-learning-hardware-guide/)

---

## Final Checklist

### Pre-Purchase
- [ ] Budget approved (~$8,000)
- [ ] eBay account created
- [ ] Workspace prepared
- [ ] Tools acquired

### Purchasing
- [ ] ASRock ROMED8-2T ordered
- [ ] AMD EPYC 7443P ordered
- [ ] SP3 CPU cooler ordered
- [ ] 8× 32GB DDR4 ECC ordered
- [ ] 4× RTX 3090 ordered
- [ ] 1× RTX 5090 ordered
- [ ] 4TB NVMe ordered
- [ ] 2× 1600W PSU ordered
- [ ] 5× PCIe risers ordered
- [ ] Mining frame ordered
- [ ] Monitor, keyboard, mouse ordered
- [ ] Accessories ordered (paste, cables, fans)

### Assembly
- [ ] Frame assembled
- [ ] Motherboard installed
- [ ] CPU and cooler installed
- [ ] RAM installed (all 8 sticks)
- [ ] NVMe installed
- [ ] GPUs installed (all 5)
- [ ] Power connected correctly
- [ ] Fans installed and connected
- [ ] Cables managed
- [ ] Pre-power-on checklist complete

### Testing
- [ ] System POSTs successfully
- [ ] BIOS configured
- [ ] All 5 GPUs detected
- [ ] Memory test passed
- [ ] CPU stress test passed
- [ ] GPU stress test passed
- [ ] Temperatures acceptable
- [ ] OS installed (RHEL 10.1)

### Software (Next Steps)
- [ ] NVIDIA drivers installed
- [ ] Docker installed
- [ ] vLLM configured
- [ ] Open WebUI running
- [ ] First model downloaded
- [ ] System producing inference

---

**Build Complete!** 🎉

You now have a professional-grade, multi-GPU LLM inference workstation capable of running the largest open-source language models.

**Total GPU Memory:** 128GB (96GB RTX 3090 + 32GB RTX 5090)  
**Total System Memory:** 256GB DDR4  
**Total Compute:** 24C/48T CPU + 74,240 CUDA cores  
**Total Cost:** ~$8,000 (60-70% savings vs new)

**Ready for:** Llama 3.1 70B, Mixtral 8x22B, Qwen 72B, and more!

---

**Last Updated:** February 2026  
**Target Budget:** $7,000 - $9,000 (used components)  
**Build Difficulty:** Advanced (Estimated 6-8 hours)
