# AI FITNESS & NUTRITION APP - COMPLETE SPECIFICATION

**Technology Stack:** Flutter (Cross-platform)  
**AI Engine:** Gemini API (Text & Vision)  
**Backend:** Firebase (Auth, Firestore, Storage)  
**Design Theme:** Dark Blue · Modern · Professional · Minimalist

---

## 1. SPLASH SCREEN

### Purpose
- Brand introduction with animated logo
- Initialize core app services
- Authenticate user session
- Load cached data for faster experience

### Visual Elements
- Animated gradient background (dark blue to navy)
- Pulsating app logo with tagline: "Your AI-Powered Fitness Journey"
- Loading progress indicator
- Version number at bottom

### Functional Working
1. **Initialization Sequence:**
   - Load environment variables (.env file)
   - Initialize Firebase SDK
   - Initialize Gemini API connection
   - Check network connectivity
   - Verify auth token validity
   - Load user preferences from local storage

2. **Navigation Logic:**
   - If first-time user → Onboarding Screens
   - If user logged in but profile incomplete → User Profile Setup
   - If returning user with complete profile → Home Dashboard
   - If network error → Offline mode notification

3. **Background Tasks:**
   - Sync pending workout data
   - Download updated exercise database
   - Fetch notification permissions
   - Pre-cache commonly used images

### Error Handling
- Network failure: Show retry option
- API initialization failure: Graceful degradation to offline mode
- Auth token expired: Redirect to login

---

## 2. ONBOARDING SCREENS (4 SCREENS)

### Purpose
- Educate new users about app capabilities
- Build excitement and trust
- Set expectations for AI personalization

### Screen 1: Welcome & AI Introduction
**Visual:** 3D illustration of AI brain
**Content:**
- "Meet Your Personal AI Fitness Coach"
- "Powered by advanced AI to create plans just for YOU"
- Key benefit: Personalized, adaptive, science-backed

### Screen 2: Smart Workout Planning
**Visual:** Animated workout demonstration
**Content:**
- "AI-Generated Workout Plans"
- "Adapts to your progress, equipment, and goals"
- "No more guessing - let AI optimize your training"

### Screen 3: Intelligent Nutrition Guidance
**Visual:** Food scanning animation
**Content:**
- "Scan Any Food, Know Its Nutrition"
- "AI creates meal plans based on your preferences"
- "Track calories effortlessly with AI assistance"

### Screen 4: 24/7 AI Coach
**Visual:** Chat interface mockup
**Content:**
- "Your Personal Trainer, Anytime"
- "Ask anything about fitness, nutrition, or recovery"
- "Get instant, personalized advice"

### Functional Working
1. **Navigation:**
   - Swipe gesture or "Next" button
   - Progress dots indicator
   - "Skip" option on all screens
   - "Get Started" on final screen

2. **State Management:**
   - Save onboarding completion flag to local storage
   - Track which screens were viewed
   - Store timestamp of first app launch

3. **Animations:**
   - Smooth page transitions
   - Auto-play screen animations
   - Parallax scrolling effects

---

## 3. AUTHENTICATION SCREENS

### 3.1 LOGIN SCREEN

#### Visual Elements
- Large app logo at top
- Email input field with validation
- Password input with show/hide toggle
- "Remember me" checkbox
- "Forgot Password?" link
- Social login buttons (Google, Apple)
- "Don't have an account? Sign Up" link

#### Functional Working
1. **Email/Password Login:**
   - Real-time input validation
   - Email format check
   - Password strength indicator
   - Firebase Authentication API call
   - Store auth token securely
   - Navigate to appropriate screen based on profile completion

2. **Social Login:**
   - Google Sign-In integration
   - Apple Sign-In (iOS)
   - Auto-create profile with social data
   - Link accounts if email exists

3. **Security Features:**
   - Rate limiting (max 5 attempts)
   - Biometric login option (fingerprint/face)
   - Secure token storage
   - Auto-logout after inactivity

### 3.2 REGISTRATION SCREEN

#### Visual Elements
- Full name input
- Email with verification
- Password with strength meter
- Confirm password
- Terms & conditions checkbox
- Privacy policy link

#### Functional Working
1. **Validation:**
   - Name: min 2 characters
   - Email: valid format + uniqueness check
   - Password: min 8 chars, 1 uppercase, 1 number, 1 special char
   - Password match confirmation

2. **Registration Flow:**
   - Create Firebase account
   - Send email verification
   - Create user document in Firestore
   - Navigate to Profile Setup

3. **Email Verification:**
   - Send verification link
   - Allow app usage with reminder banner
   - Lock premium features until verified

### 3.3 PASSWORD RESET

#### Functional Working
- Email input
- Firebase password reset email
- Success confirmation
- Redirect to login

---

## 4. USER PROFILE SETUP (AI DATA COLLECTION)

### Purpose
- Gather comprehensive data for AI personalization
- Establish baseline metrics
- Set realistic goals

### 4.1 BASIC INFORMATION (Step 1/5)

#### Inputs:
- **Full Name:** Text field
- **Age:** Number picker (13-100)
- **Gender:** Radio buttons (Male, Female, Other, Prefer not to say)
- **Profile Photo:** Camera/gallery upload (optional)

#### Validation:
- Age must be 13+ (legal compliance)
- Name cannot be empty
- Photo upload size limit: 5MB

### 4.2 BODY METRICS (Step 2/5)

#### Inputs:
- **Height:** 
  - Unit toggle (cm/feet-inches)
  - Number input with validation
  - Range: 100-250 cm
- **Current Weight:**
  - Unit toggle (kg/lbs)
  - Decimal input
  - Range: 30-300 kg
- **Target Weight:**
  - Same unit as current weight
  - Validation: realistic goal (not more than 1kg/week loss recommended)
- **Body Type:** Visual selection (Ectomorph/Mesomorph/Endomorph) with descriptions

#### AI Context:
- Calculate BMI automatically
- Determine healthy weight range
- Flag if goals seem unrealistic

### 4.3 FITNESS PROFILE (Step 3/5)

#### Inputs:
- **Primary Fitness Goal:** (Select one)
  - Fat Loss (Calorie deficit focus)
  - Muscle Gain (Calorie surplus + strength training)
  - Maintain Fitness (Maintenance calories)
  - Improve Endurance (Cardio focus)
  - Increase Flexibility (Yoga/stretching focus)
  - General Health (Balanced approach)

- **Current Fitness Level:**
  - Beginner (0-6 months training)
  - Intermediate (6-24 months training)
  - Advanced (2+ years training)
  - Athlete (Competitive level)

- **Activity Level:**
  - Sedentary (Office job, minimal activity)
  - Lightly Active (1-2 days/week exercise)
  - Moderately Active (3-5 days/week exercise)
  - Very Active (6-7 days/week exercise)
  - Athlete (Multiple training sessions daily)

- **Available Equipment:**
  - Multi-select checkboxes:
    - No equipment (bodyweight)
    - Dumbbells
    - Resistance bands
    - Pull-up bar
    - Full gym access
    - Home gym
  - Custom equipment entry

- **Workout Location:**
  - Home
  - Gym
  - Outdoor
  - Mixed

- **Workout Duration Preference:**
  - 15-30 minutes
  - 30-45 minutes
  - 45-60 minutes
  - 60+ minutes

### 4.4 NUTRITION PROFILE (Step 4/5)

#### Inputs:
- **Dietary Preference:**
  - Vegetarian
  - Non-Vegetarian
  - Vegan
  - Pescatarian
  - Keto
  - Paleo
  - No preference

- **Regional Cuisine:**
  - Auto-detect from location
  - Manual selection: Indian, Mediterranean, Asian, American, etc.
  - Used for meal suggestions

- **Food Allergies:** (Multi-select + custom entry)
  - Common: Nuts, Dairy, Gluten, Eggs, Soy, Shellfish
  - Custom text field for others

- **Foods to Avoid:**
  - Free text area
  - Examples shown: "spicy food, mushrooms, seafood"

- **Meals Per Day:**
  - Slider: 2-6 meals
  - Default: 3 main + 2 snacks

- **Water Intake Goal:**
  - Auto-calculated based on weight
  - Adjustable: 1-5 liters

### 4.5 HEALTH & LIFESTYLE (Step 5/5)

#### Inputs:
- **Medical Conditions:**
  - Checkboxes: Diabetes, Hypertension, Heart condition, Asthma, Joint issues, Back problems
  - "None" option
  - Custom entry field

- **Current Medications:**
  - Yes/No toggle
  - If yes: text field for details
  - Used to flag potential exercise contraindications

- **Injuries/Limitations:**
  - Free text area
  - Examples: "Knee injury, avoid jumping exercises"

- **Average Sleep:**
  - Slider: 4-12 hours
  - Used for recovery recommendations

- **Stress Level:**
  - Scale 1-10
  - Affects workout intensity recommendations

- **Smoking/Alcohol:**
  - Never/Occasionally/Regularly options
  - Affects health calculations

#### Completion Actions:
1. **AI Profile Generation:**
   - Send all data to Gemini
   - Generate initial assessment
   - Calculate TDEE (Total Daily Energy Expenditure)
   - Create baseline workout plan
   - Generate first week meal plan

2. **Database Storage:**
   - Save profile to Firestore
   - Create user health document
   - Initialize tracking collections

3. **Welcome Message:**
   - Show loading screen: "Your AI coach is analyzing your profile..."
   - Display personalized welcome message from AI
   - Navigate to Home Dashboard

---

## 5. HOME DASHBOARD

### Purpose
- Central hub for daily fitness activities
- At-a-glance progress overview
- Quick access to all features

### Visual Layout (Scrollable)

#### Header Section:
- **Greeting:** "Good Morning, [Name]!"
- **Current Date & Day**
- **Motivational Quote:** Daily AI-generated quote
- **Streak Counter:** Days of consecutive activity

#### Today's Overview Card:
- **Workout Status:**
  - "Today's Workout: Upper Body Strength" (if scheduled)
  - Progress bar: 0/6 exercises completed
  - "Start Workout" CTA button
  - "No workout today" with rest day icon (if rest day)

- **Nutrition Status:**
  - Calorie ring chart: Consumed/Target/Remaining
  - Macro breakdown mini-bars (Protein, Carbs, Fats)
  - "Log Meal" quick action

- **Water Intake:**
  - Visual: 8 water glasses
  - Tap to mark as consumed
  - Progress: "5/8 glasses"

- **Steps Today:**
  - Pedometer integration
  - Progress bar with steps count
  - Goal: "7,500/10,000 steps"

#### AI Suggestion Card:
**Title:** "Your AI Coach Suggests"
- Dynamic content based on:
  - Time of day
  - Recent activity
  - Progress patterns
  - Weather (if location enabled)
- Examples:
  - Morning: "Great time for a fasted cardio session!"
  - Evening: "Your energy levels are optimal for weight training now"
  - Rest day: "Focus on active recovery - try a 20-minute walk"

#### Quick Actions Grid:
- **Start Workout** (large primary button)
- **Scan Food** (camera icon)
- **Log Meal**
- **Ask AI Coach** (chat icon)
- **View Progress**
- **Water Reminder**

#### Upcoming Section:
- **Next Workout:** "Tomorrow: Lower Body - 45 min"
- **Meal Prep Reminder:** "Prep meals for tomorrow"
- **Supplement Reminder:** If user has set any

#### Weekly Summary Card:
- **Workouts Completed:** 4/5
- **Avg Daily Calories:** 1,850
- **Weight Change:** -0.5 kg (with trend arrow)
- **Consistency Score:** 85% (AI-calculated)

#### Bottom Navigation Bar:
- Home (active)
- Workouts
- Nutrition
- Progress
- Profile

### Functional Working

#### Real-Time Updates:
- Pull to refresh all data
- Auto-sync every 5 minutes
- Update workout status when exercises completed
- Real-time calorie tracking
- Water intake updates instantly

#### AI Processing:
1. **Morning Routine (6-8 AM):**
   - Gemini analyzes previous day
   - Generates today's motivation
   - Adjusts workout if user showed fatigue yesterday
   - Checks if rest day needed

2. **Continuous Learning:**
   - Track user interaction patterns
   - Note which suggestions are followed
   - Adapt recommendation timing
   - Personalize content tone

3. **Context-Aware Suggestions:**
   ```
   Prompt to Gemini:
   "User: [name], Goal: [fat loss], Last workout: [yesterday - completed], 
   Today's planned workout: [upper body], Current time: [10:00 AM],
   Weather: [sunny, 25°C], User's typical workout time: [evening],
   Recent adherence: [85%]. Generate one motivational and actionable 
   fitness suggestion for right now. Keep it under 20 words."
   ```

#### Notifications Integration:
- Workout reminder (customizable time)
- Meal time reminders
- Water reminders (every 2 hours)
- Motivational push notifications
- Progress milestone achievements

---

## 6. AI WORKOUT PLANNER

### Purpose
- Generate scientifically-backed, personalized workout programs
- Adapt plans based on progress and feedback
- Provide progressive overload

### 6.1 WORKOUT PLANS VIEW

#### Visual Layout:
- **Tab Navigation:**
  - This Week (default)
  - Next Week
  - Custom Plan
  - Exercise Library

#### This Week View:
**Weekly Calendar Grid:**
- 7 days with workout cards
- Each day shows:
  - Workout type (e.g., "Upper Body Strength")
  - Duration: 45 minutes
  - Exercises count: 6 exercises
  - Difficulty indicator (Beginner/Intermediate/Advanced)
  - Status: Scheduled/Completed/Skipped
  - Rest day badge (if applicable)

**Day Card Details (Expandable):**
- Exercise list preview (first 3 exercises)
- Muscle groups targeted (icons)
- Estimated calories burned
- "Start Workout" button
- "Reschedule" option
- "Get Alternative Plan" (AI generates new plan)

#### Workout Types Included:
- **Strength Training:** Upper body, Lower body, Full body, Push/Pull/Legs
- **Cardio:** HIIT, Steady-state, Interval training
- **Functional:** Circuit training, CrossFit-style
- **Flexibility:** Yoga, Stretching routines
- **Recovery:** Active recovery, Mobility work

### 6.2 WORKOUT GENERATION PROCESS

#### AI Prompt Structure:
```
System Context:
User Profile: {
  Name: [name],
  Age: [age],
  Gender: [gender],
  Fitness Level: [beginner/intermediate/advanced],
  Goal: [fat loss/muscle gain/endurance],
  Available Equipment: [list],
  Workout Location: [home/gym],
  Duration Preference: [30-45 minutes],
  Days Per Week: [4 days],
  Injuries/Limitations: [knee pain - avoid jumping],
  Previous Week Performance: {
    Workouts Completed: 3/4,
    Average Exercise Completion: 85%,
    Exercises Skipped: [Burpees - too difficult],
    Feedback: "Loved deadlifts, struggled with cardio"
  }
}

Generate a 7-day workout plan in JSON format with:
- Progressive difficulty
- Varied muscle group targeting
- Rest days strategically placed
- Alternative exercises for limitations
- Warm-up and cool-down routines

Return format:
{
  "week_number": 1,
  "plan_name": "Strength Building Foundation",
  "days": [
    {
      "day": "Monday",
      "rest_day": false,
      "workout_name": "Upper Body Strength",
      "duration_minutes": 45,
      "difficulty": "intermediate",
      "muscle_groups": ["chest", "shoulders", "triceps"],
      "estimated_calories": 280,
      "warm_up": [...],
      "exercises": [
        {
          "name": "Bench Press",
          "sets": 3,
          "reps": "8-10",
          "rest_seconds": 90,
          "notes": "Focus on controlled descent",
          "alternative": "Push-ups (if no bench)",
          "tutorial_url": "link",
          "muscle_target": "chest"
        }
      ],
      "cool_down": [...]
    }
  ],
  "weekly_focus": "Building strength foundation with compound movements",
  "tips": ["Ensure proper form", "Stay hydrated", "Track your weights"]
}
```

#### Plan Adaptation Logic:
1. **Week 1-2:** Foundation building, moderate intensity
2. **Week 3-4:** Increase volume (more sets/reps)
3. **Week 5-6:** Increase intensity (heavier weights, harder exercises)
4. **Week 7-8:** Peak week, then deload

#### Auto-Regeneration Triggers:
- Every Sunday night (generate next week)
- User completes 80%+ of workouts (increase difficulty)
- User completes <50% (reduce difficulty)
- User reports injury (modify plan)
- User changes goals (complete replanning)

### 6.3 EXERCISE LIBRARY

#### Features:
- **Search Bar:** Search by exercise name, muscle group, equipment
- **Filters:**
  - Muscle group
  - Equipment needed
  - Difficulty level
  - Exercise type (strength/cardio/flexibility)

#### Exercise Card:
- Exercise name
- GIF/Video demonstration
- Difficulty rating
- Primary/secondary muscles
- Equipment required
- Detailed instructions (expandable)
- Common mistakes to avoid
- "Add to Custom Workout" button
- "Ask AI about this exercise" button

#### AI-Enhanced Features:
- "Show me similar exercises"
- "Easier/Harder alternatives"
- "Exercises for same muscle group"
- Form check via video upload (future feature)

---

## 7. WORKOUT SESSION SCREEN

### Purpose
- Guide user through real-time workout
- Track performance accurately
- Provide motivation and form cues

### Visual Layout

#### Header:
- Workout title: "Upper Body Strength"
- Progress: "Exercise 3/6"
- Overall timer: "18:35 elapsed"
- Exit workout button (with save confirmation)

#### Main Exercise Display:
- **Large Exercise Name:** "Dumbbell Bench Press"
- **GIF/Video Loop:** Proper form demonstration
- **Current Set Display:** "Set 2 of 3"
- **Target:** "8-10 reps"
- **Rest Timer:** Countdown after set completion

#### Control Buttons:
- **Set Completed:** Large primary button
  - Records reps performed (quick picker: 6/7/8/9/10)
  - Records weight used (if applicable)
  - Starts rest timer automatically
- **Skip Exercise:** Secondary button
  - AI asks reason: Too difficult/Equipment unavailable/Injury concern
  - Suggests alternative immediately
- **Need Help?:** Opens AI coach chat overlay

#### Bottom Sheet (Expandable):
- **Exercise Instructions:**
  - Step-by-step written guide
  - Key points (3-4 bullets)
  - Common mistakes
- **Exercise History:**
  - Last time performed
  - Weight progression
  - Personal record
- **Muscle Map:**
  - Visual highlighting of targeted muscles

### Functional Working

#### Pre-Workout:
1. **Workout Summary Screen:**
   - Full exercise list
   - Total estimated time
   - Equipment check: "Do you have all required equipment?"
   - "Start Workout" button

2. **Warm-Up Routine:**
   - 5-minute guided warm-up
   - Dynamic stretches
   - Skip option available

#### During Workout:

**Exercise Flow:**
```
For each exercise:
1. Show exercise name + demo GIF
2. Display target sets/reps
3. 5-second preparation countdown
4. User performs exercise
5. User taps "Set Completed"
   - Quick reps/weight input
   - AI logs data
6. Rest timer starts (e.g., 90 seconds)
   - Large countdown display
   - "Skip Rest" option
   - "Add 30 sec" option
7. Rest complete -> Move to next set or exercise
8. Repeat until workout complete
```

**Rest Timer Features:**
- Visual circular countdown
- Motivational quotes during rest
- Next exercise preview (last 10 seconds)
- Background music continues
- Vibration alert at 10s, 5s, 0s

**Performance Tracking:**
- Every set logged: Exercise, Sets, Reps, Weight, Rest time
- Real-time volume calculation (Sets × Reps × Weight)
- Compare to previous workout: "Last time: 3×8×25kg, Today: 3×10×25kg (+20% volume)"

#### Adaptive AI Features:

**During Rest:**
```
AI Prompt: "User just completed Set 2 of Bench Press, did 8 reps at 30kg, 
target was 8-10 reps. Last set was 10 reps. Provide a brief encouraging 
comment (15 words max) and suggest if they should increase/maintain/decrease 
weight for next set."

AI Response Examples:
- "Solid set! You've got one more in you. Maintain 30kg for final set."
- "Great strength! Consider adding 2.5kg next workout."
- "Form over weight - if reps feel tough, drop to 27.5kg"
```

**Struggle Detection:**
- If user skips exercise → "What can I help with? Too difficult/No equipment/Injury?"
- If user takes very long rest (2× normal) → "Take your time! Let me know if you need an easier alternative."
- If user completes less than target reps 2× in a row → "Let's adjust the weight for optimal results."

**Real-Time Form Cues:**
- Pre-written tips displayed during exercise
- Examples: "Keep core tight", "Control the descent", "Full range of motion"
- Rotate through tips each set

#### Post-Set Actions:
- **Quick Log:**
  - Tap completed set
  - Reps picker appears: 6/7/8/9/10/11/12 (most common ranges)
  - If weight used: Weight input (remembers last used weight)
  - One-tap confirm

- **Replace Exercise:**
  - AI generates 3 alternatives instantly
  - Same muscle group
  - Available equipment
  - Similar difficulty
  - User selects, workout continues seamlessly

#### Cool-Down:
- 5-minute guided cool-down
- Static stretches for worked muscles
- "Skip Cool-Down" option (AI discourages)

#### Workout Summary:
- **Completion Confetti Animation**
- **Stats Card:**
  - Total time: 43 minutes
  - Exercises completed: 6/6
  - Total volume lifted: 3,450 kg
  - Estimated calories burned: 285 kcal
  - Personal records: 2 (highlighted)
- **AI Feedback:**
  - "Incredible workout! You increased your volume by 15% compared to last week."
  - "Focus area for next time: Try to reduce rest periods slightly for better endurance."
- **Share Options:** Social media, Screenshot
- **Save & Continue** button

### Integration Features

#### Music Integration:
- Spotify/Apple Music integration
- Workout playlists
- BPM-matched for cardio
- Auto-pause during rest
- Volume adjustments during instructions

#### Smartwatch Sync:
- Heart rate monitoring
- Real-time heart rate zones display
- Calorie burn accuracy improvement
- Vibration alerts

#### Video Recording (Optional):
- Record set for form review
- AI form analysis (future feature)
- Compare to demo video

---

## 8. AI NUTRITION & MEAL PLANNER

### Purpose
- Personalized nutrition planning
- Macro tracking and optimization
- Sustainable eating habits

### 8.1 NUTRITION DASHBOARD

#### Visual Layout (Daily View):

**Header:**
- Date selector (swipeable calendar)
- "Today's Nutrition" title
- Quick scan button (camera icon)

**Calorie Ring Chart:**
- Large circular progress indicator
- Center displays: "1,647 / 2,100 cal"
- Color-coded sections:
  - Green: Within target (±100 cal)
  - Yellow: Slightly over/under (±200 cal)
  - Red: Significantly off target
- Subtitle: "453 cal remaining"

**Macronutrient Breakdown:**
- Three horizontal progress bars:
  - **Protein:** 142g / 157g (Blue) - 90%
  - **Carbs:** 189g / 236g (Orange) - 80%
  - **Fats:** 51g / 70g (Purple) - 73%
- Percentage indicators
- "Balanced" or "Adjust" status badge

**Today's Meals Section:**
- **Breakfast** (7:30 AM)
  - Meal name: "Oatmeal with Berries"
  - Calories: 420 kcal
  - Macros: P: 15g | C: 68g | F: 12g
  - Thumbnail image
  - Edit/Delete icons

- **Snack** (10:00 AM)
  - "Protein Shake"
  - 250 kcal
  - Quick add option

- **Lunch** (Not logged)
  - "Log Lunch" CTA
  - AI suggestion: "Try grilled chicken salad"

- **Snack** (Empty)
- **Dinner** (Empty)

**Water Intake Tracker:**
- Visual: 8 glass icons
- Tap to fill
- Progress: 5/8 glasses (1.6L / 2.5L)
- Reminder toggle

**Supplement Tracker:**
- Checklist for daily supplements
- Examples: Multivitamin ✓, Omega-3 ✓, Protein ✗

### 8.2 AI MEAL PLAN GENERATION

#### Weekly Meal Plan View:

**Generation Screen:**
- "Generate New Meal Plan" button
- Customization options:
  - Duration: 3 days / 1 week / 2 weeks
  - Budget level: Economy / Standard / Premium
  - Cooking complexity: Simple / Moderate / Advanced
  - Repeat favorites: Yes/No toggle
  - New foods to try: Yes/No toggle

**AI Meal Plan Prompt:**
```
Generate a 7-day meal plan for:
User Profile: {
  Goal: Fat loss,
  Target Calories: 2,100 kcal/day (deficit of 300),
  Macros: Protein 157g (30%), Carbs 236g (45%), Fats 70g (25%),
  Diet: Vegetarian,
  Allergies: None,
  Dislikes: Mushrooms, bitter gourd,
  Regional Preference: Indian cuisine,
  Meals Per Day: 3 main + 2 snacks,
  Budget: Standard (~$10/day),
  Cooking Skill: Moderate,
  Previous liked meals: [Paneer tikka, Dal tadka, Greek yogurt parfait]
}

Return JSON format:
{
  "week_plan": {
    "total_calories_avg": 2,095,
    "macro_accuracy": "98%",
    "days": [
      {
        "day": "Monday",
        "date": "2025-12-16",
        "total_calories": 2,110,
        "meals": [
          {
            "meal_type": "Breakfast",
            "time": "8:00 AM",
            "name": "Masala Oats with Vegetables",
            "description": "Savory oats cooked with mixed vegetables and Indian spices",
            "calories": 380,
            "protein": 12,
            "carbs": 58,
            "fats": 10,
            "ingredients": [
              "Oats - 50g",
              "Mixed vegetables - 100g",
              "Cumin seeds - 1 tsp",
              "Turmeric - 1/4 tsp"
            ],
            "recipe": {
              "prep_time": "5 min",
              "cook_time": "10 min",
              "difficulty": "Easy",
              "steps": [
                "Heat oil, add cumin seeds",
                "Add vegetables, sauté for 3 mins",
                "Add oats and 1.5 cups water",
                "Cook until creamy, add spices"
              ]
            },
            "alternatives": ["Poha", "Upma", "Vegetable dalia"]
          }
        ]
      }
    ]
  },
  "shopping_list": {
    "groceries": ["Oats - 500g", "Paneer - 400g", ...],
    "estimated_cost": "$68"
  },
  "weekly_prep_guide": "Meal prep on Sunday: Cook rice, chop vegetables, marinate paneer..."
}
```

#### Meal Plan Display:

**Weekly Grid View:**
- 7-day calendar
- Each day shows meal thumbnails
- Total calories per day
- Swap day button

**Daily Detailed View:**
- Scrollable meal cards for the day
- Each meal expandable for:
  - Full ingredient list
  - Step-by-step recipe
  - Cooking time
  - Difficulty level
  - Nutritional breakdown
  - Alternative meal suggestions (3 options)
  - "Cook this meal" tutorial mode
  - Add to favorites
  - Share recipe

**Smart Features:**
- **Swap Meal:** AI generates 3 similar alternatives (same macros, diet preference)
- **Adjust Portion:** Slider to increase/decrease servings (recalculates macros)
- **Leftover Planning:** AI suggests using yesterday's dinner for today's lunch
- **Batch Cooking:** AI identifies meals that can be meal-prepped

**Shopping List Integration:**
- Auto-generated from meal plan
- Categorized by grocery section (Produce, Dairy, Grains, etc.)
- Quantity calculations
- Check-off list for shopping
- Export to notes or share

### 8.3 FOOD LOGGING

#### Manual Food Entry:

**Search Food Database:**
- Search bar: "Search foods..."
- Recent foods (quick add)
- Favorite foods
- Custom foods (user-created)
- Popular searches

**Food Details:**
- Food name
- Serving size selector (dropdown: 1 serving, 100g, 1 cup, etc.)
- Quantity adjuster
- Real-time macro calculation
- Add to meal button (Breakfast/Lunch/Dinner/Snack)

**Custom Food Creation:**
- Food name
- Serving size
- Calories, Protein, Carbs, Fats input
- Save for future use

**Quick Add:**
- Calorie-only quick log
- Example: "Quick add 300 calories"
- Used for estimated meals

### 8.4 AI FOOD SCANNER (UNIQUE FEATURE)

#### How It Works:

**Camera Interface:**
- Live camera view
- Capture button
- Gallery upload option
- Flash toggle
- "Tips for best results" info icon

**Scanning Process:**
1. User takes photo of food/meal
2. Loading animation: "AI is analyzing your food..."
3. Image sent to Gemini Vision API
4. AI identifies food items
5. Estimates portion sizes
6. Calculates nutrition

**AI Vision Prompt:**
```
Analyze this food image and provide:
1. Identify all food items visible
2. Estimate portion size for each
3. Calculate nutritional values
4. Return in JSON format

Context: User is vegetarian, tracking calories for fat loss.

Return:
{
  "foods_detected": [
    {
      "name": "White rice",
      "portion_size": "1 cup (cooked)",
      "grams": 200,
      "confidence": 0.92,
      "calories": 204,
      "protein": 4.2,
      "carbs": 44.5,
      "fats": 0.4
    },
    {
      "name": "Paneer curry",
      "portion_size": "1 serving",
      "grams": 150,
      "confidence": 0.85,
      "calories": 285,
      "protein": 18,
      "carbs": 8,
      "fats": 20
    }
  ],
  "total_meal": {
    "calories": 489,
    "protein": 22.2,
    "carbs": 52.5,
    "fats": 20.4
  },
  "meal_type_suggestion": "Lunch",
  "notes": "Balanced meal with good protein. Consider adding vegetables for fiber."
}
```

**Results Screen:**
- List of detected foods
- Confidence indicators
- Edit portion sizes
- Add/remove items
- Total nutrition summary
- "Log This Meal" button
- "Retake Photo" option

**AI Accuracy Features:**
- Multiple angles suggestion if confidence low
- "Does this look right?" confirmation
- Manual override for all values
- Learn from corrections

### 8.5 NUTRITION INSIGHTS & AI RECOMMENDATIONS

#### Weekly Nutrition Report:

**Generated Every Sunday:**
- Average daily calories
- Macro adherence percentage
- Meals logged consistency
- Deficit/surplus trends
- Weight correlation analysis

**AI Analysis Prompt:**
```
Analyze user's weekly nutrition data:
- Daily calories: [2,100, 1,950, 2,300, 2,050, 1,800, 2,400, 2,150]
- Target: 2,100 (deficit for fat loss)
- Weight change: -0.3kg this week
- Workout days: 4
- Rest days: 3
- Meals logged: 18/21 (86%)
- Water intake avg: 2.1L/day

Provide:
1. Overall assessment (2 sentences)
2. What went well (2 points)
3. Areas to improve (2 points)
4. Specific recommendation for next week
```

**Display Format:**
- Visual grade: A/B/C/D
- Consistency score
- AI written feedback (conversational tone)
- Actionable next steps

#### Smart Reminders:

**Meal Time Notifications:**
- Customizable meal times
- "Time for lunch! Have you logged it?"
- If not logged by 1 hour past time: "Don't forget to log your lunch"

**End of Day Summary:**
- 9 PM notification
- "You have 380 calories remaining today"
- Suggestion: "A protein shake would fit perfectly"
- Or: "You're 150 calories over. Plan lighter breakfast tomorrow."

#### AI Nutrition Coaching:

**Proactive Suggestions:**
- Under protein by 3 PM: "Try adding a boiled egg as an evening snack"
- Over carbs: "Your dinner tonight could be low-carb focused"
- Low water intake: "You've only had 3 glasses today. Drink up!"

**Pattern Detection:**
- "I noticed you skip breakfast on weekdays. This might affect your energy."
- "You consistently go over calories on weekends. Let's plan better for Saturday."
- "Great job staying consistent with protein intake!"

---

## 9. AI FITNESS CHATBOT

### Purpose
- 24/7 personalized fitness assistant
- Answer workout and nutrition questions
- Provide motivation and accountability

### Chat Interface

#### Visual Design:
- Clean messaging interface
- User messages: Right-aligned, blue bubbles
- AI responses: Left-aligned, dark gray bubbles
- Typing indicator with bouncing dots
- Time stamps
- Date separators

#### Header:
- AI Avatar (animated icon)
- Status: "Online" (always available)
- "Your AI Fitness Coach"
- Settings icon (chat preferences)

#### Input Area:
- Text input field: "Ask me anything about fitness..."
- Send button
- Microphone button (voice input)
- Attachment button (images for form check, food scan)
- Quick action chips:
  - "Workout advice"
  - "Nutrition tips"
  - "Motivate me"
  - "Exercise alternative"

### AI Capabilities

#### 1. Workout Advice:

**Example Conversation:**
```
User: "My shoulders hurt during overhead press"

AI Context: {User profile, recent workouts, known injuries}

AI Prompt: "User reported shoulder pain during overhead press. 
They have no previous shoulder injuries mentioned. Provide:
1. Potential causes (form issues, mobility, overuse)
2. Immediate advice (stop exercise, alternative)
3. When to see doctor
4. Preventive tips
Keep response under 150 words, empathetic tone."

AI Response: "I'm sorry to hear about your shoulder discomfort. 
This is common and often related to form or mobility issues. Here's what I suggest:

**Immediate Action:**
- Stop overhead pressing for now
- Try lateral raises or front raises instead (less shoulder stress)

**Likely Causes:**
- Elbows flaring out too wide
- Limited shoulder mobility
- Too heavy weight

**What to do:**
1. Record yourself doing the movement (lighter weight)
2. Ensure elbows stay at 45° angle
3. Do shoulder mobility work daily
4. If pain persists beyond 3 days, consult a physiotherapist

I've updated today's workout to replace overhead press with dumbbell lateral raises. Would you like form tips for those?"
```

#### 2. Nutrition Guidance:

**Example:**
```
User: "Can I eat pizza on a fat loss diet?"

AI Response: "Absolutely! No food is off-limits, it's about balance. Here's how:

**Smart Pizza Choices:**
- Thin crust instead of deep dish (saves ~200 cal)
- Extra veggies, less cheese
- Grilled chicken for protein
- Share a large instead of solo medium

**Make It Fit:**
A 2-slice medium pizza is ~600 calories. If your daily target is 2,100, you still have 1,500 for other meals. Just plan lighter meals around it.

**Today's Plan:**
- Breakfast: 400 cal (protein smoothie)
- Lunch: 500 cal (salad with chicken)
- Dinner: 600 cal (pizza!)
- Snacks: 300 cal

You're still in deficit and enjoying your food. That's sustainable eating! 🍕

Want me to find nearby pizza places with nutrition info?"
```

#### 3. Exercise Form Tips:

**Example:**
```
User: "How to do a proper squat?"

AI Response: "Great question! Squats are the king of leg exercises. Here's your complete guide:

**Setup:**
1. Feet shoulder-width apart
2. Toes slightly pointed out (10-15°)
3. Core engaged, chest up

**The Movement:**
1. Push hips back first (like sitting in a chair)
2. Keep knees tracking over toes
3. Descend until thighs parallel to ground
4. Drive through heels to stand
5. Squeeze glutes at top

**Common Mistakes to Avoid:**
❌ Knees caving inward
❌ Heels lifting off ground
❌ Rounding lower back
❌ Looking down (keep neutral neck)

**Pro Tips:**
- Film yourself from the side
- Start bodyweight only
- Focus on depth before weight
- Breathe: inhale down, exhale up

I can add bodyweight squats to your next workout to practice form. Want me to do that?"
```

#### 4. Motivation & Accountability:

**Example:**
```
User: "I don't feel like working out today"

AI: "I totally get it - some days are harder than others. Let's figure this out together:

**Quick Check:**
- Did you sleep well? (Rest is crucial)
- Are you sore from last workout?
- Stressed about something?

**Here's the thing:** You've worked out 4 days this week already. That's amazing! Your body might actually need rest.

**Options:**
1. **Full rest day** - Zero guilt. Recovery is progress.
2. **Light activity** - 15-min walk, gentle yoga
3. **Short workout** - Just 20 mins, you'll feel accomplished

What sounds doable right now?

Remember: 4 workouts this week is fantastic. One missed session won't undo your progress, but forcing it when exhausted might. Trust your body. 💪

What would help you most today?"
```

#### 5. Meal Suggestions:

**Example:**
```
User: "Quick high-protein breakfast ideas?"

AI: "Here are 5 quick high-protein breakfasts ready in under 10 minutes:

**1. Greek Yogurt Power Bowl** (5 min)
- 200g Greek yogurt (20g protein)
- Berries, granola, chia seeds
- **Total:** 360 cal, 25g protein

**2. Scrambled Egg Wrap** (7 min)
- 3 eggs, whole wheat wrap (24g protein)
- Veggies, hot sauce
- **Total:** 380 cal, 28g protein

**3. Protein Smoothie** (3 min)
- Scoop protein powder (25g)
- Banana, oats, almond milk
- **Total:** 320 cal, 30g protein

**4. Paneer Toast** (Indian option - 8 min)
- Grilled paneer (100g - 18g protein)
- Whole wheat toast, chutney
- **Total:** 340 cal, 22g protein

**5. Overnight Oats** (0 min - prep night before!)
- Oats, protein powder, milk
- **Total:** 400 cal, 28g protein

All fit your 2,100-calorie plan. Pick one and I'll add it to today's meal plan!"
```

### Advanced AI Features

#### Context Awareness:

**The AI remembers:**
- Previous conversations in same session
- User's fitness level and goals
- Recent workouts and performance
- Injury history and limitations
- Dietary preferences and restrictions
- Time of day (affects suggestions)
- User's typical schedule
- Previous questions asked

**Example of Context:**
```
User: "Should I train today?" (at 8 PM)

AI knows:
- User already worked out this morning
- User's plan has 1 workout per day
- User tends to overtrain

AI Response: "You crushed your morning workout! Your body needs 
recovery now. Training twice in one day isn't in your plan and 
might hurt your progress. How about a relaxing evening walk or 
stretching session instead? Rest is when muscles grow! 💤"
```

#### Multi-Turn Conversations:

```
User: "My lower back hurts"
AI: "I'm sorry to hear that. To help better, can you tell me:
1. When did it start?
2. Sharp or dull pain?
3. Related to a specific exercise?"

User: "Started yesterday after deadlifts, dull ache"
AI: "Thanks for clarifying. This sounds like delayed onset muscle 
soreness (DOMS) from deadlifts, which is normal, especially if you:
- Increased weight recently
- Changed form
- Haven't deadlifted in a while

**What helps:**
- Light movement (walking)
- Heat therapy
- Gentle stretching
- Stay hydrated

**Red flags** (see doctor if):
- Sharp shooting pain
- Numbness in legs
- Pain worsens over 3 days

For now, I've modified your workout plan to avoid lower back 
exercises for 2-3 days. You'll do upper body instead. Sound good?"
```

#### Safety & Disclaimers:

**The AI ALWAYS:**
- Recommends seeing healthcare professionals for persistent pain
- Doesn't diagnose medical conditions
- Emphasizes proper form over heavy weights
- Discourages extreme diets or supplements
- Promotes sustainable, healthy practices

**Built-in Safeguards:**
```
System Instruction to Gemini:
"You are a fitness AI assistant. You must:
- NEVER diagnose medical conditions
- ALWAYS recommend seeing doctors for injuries/pain
- NEVER recommend steroids or dangerous supplements
- AVOID extreme diets (under 1200 cal for women, 1500 for men)
- PRIORITIZE user safety over results
- DISCOURAGE overtraining and obsessive behavior
- PROMOTE body positivity and mental health

If user asks about dangerous practices, politely decline and 
explain health risks."
```

#### Suggested Quick Questions (Displayed):
- "What should I eat pre-workout?"
- "How to increase my squat?"
- "Alternatives to running?"
- "Is soreness good or bad?"
- "How much protein do I need?"
- "Should I do cardio or weights first?"

---

## 10. PROGRESS & ANALYTICS

### Purpose
- Visualize fitness journey
- Track multiple metrics
- Identify patterns and plateaus
- Celebrate milestones

### 10.1 PROGRESS DASHBOARD

#### Time Range Selector:
- Tabs: Week / Month / 3 Months / Year / All Time
- Date range picker
- Export data button

### 10.2 WEIGHT TRACKING

#### Visual Display:
**Line Graph:**
- X-axis: Dates
- Y-axis: Weight (kg/lbs)
- Plot points for each weigh-in
- Trend line (linear regression)
- Target weight line (dotted)
- Color-coded zones:
  - Green: Within healthy range
  - Yellow: Approaching plateau
  - Red: Unhealthy rate of change

**Stats Cards:**
- **Starting Weight:** 82.5 kg (Jan 1)
- **Current Weight:** 78.3 kg
- **Goal Weight:** 75 kg
- **Lost:** -4.2 kg
- **Remaining:** 3.3 kg
- **Avg Weekly Loss:** -0.35 kg
- **ETA to Goal:** 9 weeks (AI-calculated)

#### Input Section:
- "Log Today's Weight" button
- Quick input field
- Optional: Body measurements (chest, waist, hips, arms, thighs)
- Photo progress (front, side, back)
- Notes field

#### AI Insights:
```
"Great progress! You're losing at a healthy rate of 0.35kg per week. 
This is sustainable and you're preserving muscle. 

**Observations:**
- Consistent deficit adherence
- Weight slightly up last week (normal fluctuation)
- On track to reach 75kg by end of February

**Recommendation:** Keep current calories. You're doing great!"
```

### 10.3 BODY MEASUREMENTS

#### Measurement Tracking:
- Chest
- Waist
- Hips
- Left Arm / Right Arm
- Left Thigh / Right Thigh
- Calves

#### Visual Display:
- Line graphs for each measurement
- Body silhouette with measurement points
- Change indicators (+/- from last measurement)
- Before/after comparison slider

#### Progress Photos:
- Timeline grid of progress photos
- Filter by: Front / Side / Back
- Date stamps
- Before/after comparison mode
- Privacy: Face blur option
- Local storage only (not uploaded unless user shares)

### 10.4 WORKOUT ANALYTICS

#### Workout Consistency:

**Calendar Heatmap:**
- GitHub-style contribution graph
- Each day colored by workout completion:
  - Dark green: Workout completed
  - Light green: Partial workout
  - Gray: Rest day (planned)
  - Red: Missed workout
- Streak counter
- Longest streak highlight

**Stats:**
- **This Month:** 18/22 workouts completed (82%)
- **This Year:** 156/180 workouts (87%)
- **Current Streak:** 12 days
- **Longest Streak:** 24 days

#### Volume & Strength Progression:

**Total Volume Lifted:**
- Bar chart: Weekly total volume (Sets × Reps × Weight)
- Progressive overload indicator
- Example: Week 1: 12,500 kg → Week 12: 18,750 kg (+50%)

**Exercise-Specific Progression:**
- Select exercise from dropdown
- Line graph showing max weight used over time
- Example: Bench Press progression:
  - Jan 1: 60kg × 5 reps
  - Mar 1: 75kg × 5 reps (+25%)
- Personal records highlighted

**Time & Intensity:**
- Average workout duration by week
- Rest time trends (decreasing = improving endurance)
- Exercises performed (variety metric)

### 10.5 NUTRITION ANALYTICS

#### Calorie Adherence:

**Weekly Bar Chart:**
- Target calories (horizontal line)
- Actual calories (bars)
- Color-coded:
  - Green: Within ±100 cal
  - Yellow: ±200 cal
  - Red: >200 cal deviation
- Weekly average display

#### Macro Trends:

**Stacked Area Chart:**
- 3 colored areas (Protein, Carbs, Fats)
- Shows distribution over time
- Hover for exact values

**Macro Adherence Percentage:**
- Protein: 89% adherence (target: 157g, avg: 140g)
- Carbs: 85% adherence
- Fats: 91% adherence

#### Meal Logging Consistency:
- Percentage of meals logged: 86%
- Streak: 14 days consecutive logging
- Most logged meal: Breakfast (95%)
- Least logged: Snacks (68%)

### 10.6 OVERALL HEALTH METRICS

#### Water Intake:
- Daily average: 2.3L
- Hydration score: 8/10
- Best day: 3.2L
- Trend graph

#### Sleep Tracking:
- If integrated with smartwatch/health app
- Average sleep: 7.2 hours
- Sleep quality trends
- Correlation with workout performance

#### Steps & Activity:
- Daily step count graph
- Active vs. sedentary time
- Calories burned from activity
- Integration with Google Fit / Apple Health

### 10.7 AI-GENERATED PROGRESS REPORT

#### Weekly Progress Summary (Auto-Generated):

**AI Analysis Prompt:**
```
Analyze user's week:
Workouts: 5/5 completed (100%)
Weight: 78.3kg (lost 0.4kg this week)
Calories: Avg 2,050/day (target 2,100)
Macros: Protein 145g (target 157g)
Volume lifted: 15,200kg (up from 14,800kg)
Sleep: Avg 7.5 hours
Steps: Avg 8,200/day

Generate motivational progress report highlighting:
1. Biggest achievement this week
2. Area that improved most
3. Something to focus on next week
4. Personalized encouragement
```

**AI Response Example:**
```
🌟 WEEKLY PROGRESS REPORT 🌟

**This Week's MVP Moment:**
Perfect workout attendance! 5/5 completed. Your consistency is 
building serious momentum.

**Standout Improvement:**
You increased your training volume by 400kg this week while 
maintaining perfect form. That's progressive overload done right!

**Health Snapshot:**
✓ Weight: -0.4kg (healthy pace)
✓ Sleep: 7.5h avg (optimal for recovery)
✓ Nutrition: 97% calorie adherence
⚠ Protein: Slightly under target (145g vs 157g)

**Next Week Focus:**
Let's hit that protein target! Try adding:
- 1 scoop protein powder (25g)
- OR 100g extra paneer/chicken per day

**Keep This Up:**
You're 14 weeks into your journey and haven't missed a beat. 
This is the consistency that creates lasting transformation. 
Proud of you! 💪

Your AI Coach"
```

#### Monthly Milestone Celebrations:

**Auto-Triggered Celebrations:**
- Lost 5 kg
- Completed 50 workouts
- 30-day streak
- Lifted 100,000 kg total volume
- Logged 500 meals

**Celebration Screen:**
- Confetti animation
- Achievement badge
- Shareable card
- Milestone stats
- "Keep going!" message from AI

### 10.8 COMPARATIVE ANALYTICS

#### Goal Progress:

**Visual Goal Tracker:**
- Starting point marker
- Current position
- Goal endpoint
- Percentage complete
- Days remaining / days elapsed

**Example:**
```
FAT LOSS GOAL
━━━━━━━━━━━━━━━●━━━━━━ 
Start: 82.5kg    Current: 78.3kg    Goal: 75kg
         ↓             ↓                ↓
      Week 0         Week 14          Week 24
      
Progress: 56% complete
Ahead of schedule by 2 weeks!
```

#### Predictions:

**AI-Powered Forecasting:**
```
AI Prompt: "Based on 14 weeks of data:
- Weight loss rate: -0.3kg/week avg
- Adherence: 87%
- Current weight: 78.3kg
- Goal: 75kg

Predict:
1. Expected date to reach goal
2. Confidence level
3. What could accelerate progress
4. What could slow progress"

AI Response:
"Based on your consistent progress, you'll likely reach 75kg by 
February 28 (in 10 weeks) with 85% confidence.

**To get there faster:**
- Hit protein target daily (saves muscle, boosts metabolism)
- Add 1 extra cardio session weekly (250 cal burned)

**Watch out for:**
- Holiday season (Dec 20-Jan 5) - plan meals ahead
- Potential plateau around 76-77kg - we'll adjust if needed

You're on an excellent trajectory. Stay consistent!"
```

---

## 11. COMMUNITY & SOCIAL FEATURES

### Purpose
- Build accountability
- Share progress
- Learn from others
- Friendly competition

### 11.1 COMMUNITY FEED

#### Visual Layout:
- Scrollable feed of posts
- Filter by: Following / All Users / Challenges

#### Post Types:
1. **Workout Completion:**
   - User photo
   - "Just completed Upper Body Strength!"
   - Stats: Duration, Calories, Exercises
   - Like and comment buttons

2. **Progress Photo:**
   - Before/after slider
   - Weight loss milestone
   - Caption
   - Encouragement reactions

3. **Meal Share:**
   - Food photo
   - Nutrition info
   - Recipe (if available)
   - Save to favorites option

4. **Achievement:**
   - Badge earned
   - Milestone reached
   - Celebration animation

#### Privacy Settings:
- Public / Friends Only / Private
- Opt-in for each feature
- Anonymous mode option

### 11.2 CHALLENGES

#### Types of Challenges:
1. **30-Day Challenges:**
   - Plank every day
   - 10,000 steps daily
   - No sugar challenge
   - Drink 3L water daily

2. **Workout Challenges:**
   - Complete 20 workouts this month
   - Lift 50,000 kg total volume
   - Run 100 km in 30 days

3. **Community Challenges:**
   - Global step challenge
   - Weight loss leaderboard (opt-in)
   - Consistency challenge

#### Challenge Interface:
- Join challenge button
- Leaderboard (if competitive)
- Daily check-ins
- Progress tracker
- Badges for completion
- AI motivation tailored to challenge

### 11.3 FRIEND FEATURES

#### Add Friends:
- Search by username
- Connect from contacts
- QR code sharing
- Friend requests

#### Friend Dashboard:
- Friends' recent workouts
- Workout together option (sync schedules)
- Send challenges
- Encourage button (sends motivational message)
- Compare progress (optional, mutual consent)

---

## 12. SMART REMINDERS & NOTIFICATIONS

### Purpose
- Improve consistency
- Reduce forgetfulness
- Intelligent timing

### 12.1 NOTIFICATION TYPES

#### Workout Reminders:
- **Time-Based:**
  - "Your workout starts in 30 minutes! 💪"
  - Customizable time
  - Snooze option (15/30/60 min)

- **AI-Optimized Timing:**
  - Learns when user actually works out
  - Suggests best time based on completion rates
  - Example: "You usually workout at 6 PM, want to set reminder?"

#### Meal Reminders:
- Breakfast, Lunch, Dinner times
- "Don't forget to log your lunch!"
- 1-hour follow-up if not logged

#### Water Reminders:
- Every 2 hours (customizable)
- "Time for a water break! 💧"
- Auto-pause during sleep hours

#### Weigh-In Reminders:
- Weekly (same day, same time)
- "It's weigh-in day! Step on the scale."

#### Rest Day Reminders:
- "Today is your rest day. Recovery is progress!"
- Optional: Active recovery suggestions

#### Motivational Push Notifications:
- Random motivational quotes
- Progress milestones
- Streak reminders: "Don't break your 10-day streak!"

### 12.2 SMART REMINDER FEATURES

#### Adaptive Timing:
```
AI learns:
- User completes workouts at 6 PM most often
- User ignores 5 PM reminders
- User responds to 5:30 PM reminders

AI adjusts reminder to 5:30 PM automatically
```

#### Context-Aware:
- Don't remind during meetings (calendar integration)
- Don't remind when user is at gym (location services)
- Don't remind when phone is in Do Not Disturb

#### Behavior-Based:
- If user misses 3 workout reminders: "Is this time not working? Let's reschedule."
- If user logs meals without reminders: Reduce meal reminders
- If user logs water consistently: Reduce water reminders

### 12.3 IN-APP NOTIFICATIONS

#### Notification Center:
- Badge count on bell icon
- Categorized:
  - AI suggestions
  - Friend activity
  - Challenge updates
  - Achievement unlocked
  - App updates

#### Action-Oriented:
- Swipe to complete action
- Example: "Log today's weight" → Swipe → Weight input appears

---

## 13. SETTINGS & CUSTOMIZATION

### 13.1 PROFILE SETTINGS

#### Edit Profile:
- Photo
- Name, Age, Gender
- Bio (public profiles)
- Privacy settings

#### Fitness Profile:
- Update goals
- Change activity level
- Update equipment available
- Modify workout preferences

#### Nutrition Profile:
- Update diet preference
- Edit allergies
- Modify calorie target
- Change macro ratios

### 13.2 APP PREFERENCES

#### Display:
- Theme: Dark / Light / Auto
- Color accent selection
- Font size
- Units: Metric / Imperial

#### Language:
- Multiple language support
- AI responds in user's language

#### Notifications:
- Toggle each notification type
- Set quiet hours
- Notification sound

### 13.3 AI CONTROL

#### AI Personality:
- Formal / Friendly / Motivational / Humorous
- Response length: Brief / Detailed
- Frequency of AI suggestions: Minimal / Moderate / Maximum

#### Reset AI:
- "Start Fresh with AI Coach"
- Clears AI conversation history
- Regenerates all plans
- Keeps user data

#### AI Data Usage:
- What data AI uses
- Opt-out options
- Clear AI insights
- Export AI conversation history

### 13.4 DATA & PRIVACY

#### Export Data:
- Download all user data (JSON format)
- Generate PDF progress report
- Export workout history (CSV)
- Export meal log (CSV)

#### Delete Data:
- Delete specific workouts
- Delete meal logs
- Delete progress photos
- Delete entire account (with confirmation)

#### Privacy:
- Who can see my profile
- Who can see my progress
- Hide from search
- Anonymous mode

### 13.5 INTEGRATIONS

#### Health Apps:
- Google Fit integration
- Apple Health integration
- Samsung Health
- Fitbit, Garmin, Strava

#### Music Services:
- Spotify
- Apple Music
- YouTube Music

#### Calendar:
- Sync workout schedule to Google/Apple Calendar
- Block workout time automatically

---

## 14. PREMIUM FEATURES (MONETIZATION)

### 14.1 FREE vs. PREMIUM

#### Free Tier Includes:
- Basic AI workout plans (1 week at a time)
- Meal suggestions (daily)
- Food scanner (5 scans/day)
- AI chatbot (10 messages/day)
- Basic progress tracking
- Ads shown

#### Premium Tier ($9.99/month or $79.99/year):
- **Unlimited AI Access:**
  - Unlimited AI chatbot messages
  - Unlimited food scans
  - Advanced AI insights

- **Advanced Planning:**
  - 4-week workout programs
  - Monthly meal plans
  - Custom program builder
  - Exercise form video analysis (future)

- **Enhanced Tracking:**
  - Detailed analytics & trends
  - Body fat percentage tracking
  - Performance predictions
  - Compare multiple metrics

- **Exclusive Features:**
  - Priority AI responses (faster)
  - Workout plan variations (3 options to choose from)
  - Personalized supplement recommendations
  - 1-on-1 AI coaching sessions (deep dive conversations)
  - Ad-free experience

- **Community Perks:**
  - Premium badge
  - Create custom challenges
  - Host group workouts
  - Early access to new features

### 14.2 IN-APP PURCHASES

#### One-Time Purchases:
- Lifetime premium: $199.99
- Specific diet plans: $4.99 (Keto, Paleo, etc.)
- Workout programs: $9.99 (6-week beach body, marathon training)

#### Consumables:
- Extra AI messages pack: $1.99 (100 messages)
- Food scan pack: $0.99 (50 scans)

---

## 15. ONBOARDING IMPROVEMENTS & GAMIFICATION

### 15.1 GUIDED FIRST WEEK

#### Day 1-7 Tutorial:
- Daily tasks introduced gradually
- "Complete your first workout"
- "Log your first meal"
- "Chat with AI coach"
- Rewards for completion

#### Achievement System:

**Levels:**
- Novice (Week 1-2)
- Beginner (Week 3-8)
- Intermediate (Week 9-20)
- Advanced (Week 21+)
- Elite (100+ workouts)

**Badges:**
- First Workout
- 7-Day Streak
- 30-Day Streak
- 100 Workouts
- 50kg Lost (collective)
- Early Bird (workout before 7 AM)
- Night Owl (workout after 9 PM)
- Meal Prep Master (log all meals for week)
- Hydration Hero (hit water goal 30 days)

#### Points System:
- Complete workout: +100 points
- Log meal: +20 points
- Hit water goal: +10 points
- 7-day streak: +500 bonus
- Redeem for: Premium trial, Custom badges, Themes

---

## 16. TECHNICAL ARCHITECTURE

### 16.1 FRONTEND (Flutter)

#### Key Packages:
- `flutter_bloc` - State management
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `google_generative_ai` - Gemini API
- `image_picker` - Camera access
- `fl_chart` - Data visualization
- `shared_preferences` - Local storage
- `camera` - Camera functionality
- `permission_handler` - Permissions
- `intl` - Internationalization

#### Architecture:
- **BLoC Pattern** for state management
- **Repository Pattern** for data layer
- **Clean Architecture** principles

#### Folder Structure:
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/
│   ├── workout/
│   ├── nutrition/
│   ├── chatbot/
│   └── progress/
└── main.dart
```

### 16.2 BACKEND (Firebase)

#### Firestore Collections:
```
users/
  {userId}/
    - profile (document)
    - settings (document)
    - health_data (document)
    
    workouts/ (subcollection)
      {workoutId}/
        - date, exercises[], duration, calories, notes
    
    meals/ (subcollection)
      {mealId}/
        - date, meal_type, foods[], total_nutrition
    
    progress/ (subcollection)
      {date}/
        - weight, measurements, photos[], notes
    
    ai_plans/ (subcollection)
      {planId}/
        - type (workout/meal), generated_date, plan_data, active
    
    achievements/ (subcollection)
      {achievementId}/
        - badge_type, earned_date, points

workout_plans/ (global)
  {planId}/
    - name, difficulty, days[], created_by, public

exercises/ (global database)
  {exerciseId}/
    - name, muscle_groups[], equipment, difficulty, tutorial_url

challenges/ (global)
  {challengeId}/
    - name, type, start_date, end_date, participants[], leaderboard[]
```

#### Firebase Storage Structure:
```
users/{userId}/
  profile_photo.jpg
  progress_photos/
    {date}_front.jpg
    {date}_side.jpg
    {date}_back.jpg
  food_scans/
    {timestamp}.jpg
```

#### Security Rules:
- Users can only read/write their own data
- Exercise database readable by all
- Public challenges readable by all
- Admin role for global content

### 16.3 GEMINI API INTEGRATION

#### API Configuration:
```dart
final gemini = GenerativeModel(
  model: 'gemini-pro',
  apiKey: dotenv.env['GEMINI_API_KEY']!,
);

final geminiVision = GenerativeModel(
  model: 'gemini-pro-vision',
  apiKey: dotenv.env['GEMINI_API_KEY']!,
);
```

#### Usage Optimization:
- **Caching:** Cache AI responses for 24 hours
- **Rate Limiting:** Max 100 requests/day for free users
- **Batch Requests:** Combine multiple queries when possible
- **Fallback:** Use cached plans if API fails

#### Prompt Templates:
```dart
class PromptTemplates {
  static String workoutPlan(UserProfile user) {
    return """
    Generate a personalized workout plan for:
    Goal: ${user.goal}
    Level: ${user.fitnessLevel}
    Equipment: ${user.equipment.join(', ')}
    Days/week: ${user.workoutDays}
    Duration: ${user.preferredDuration} minutes
    Limitations: ${user.injuries}
    
    Return JSON with 7-day plan including exercises, sets, reps.
    """;
  }
  
  static String mealPlan(UserProfile user) {
    return """
    Create a ${user.dietPreference} meal plan for:
    Calories: ${user.targetCalories}
    Macros: P${user.protein}g C${user.carbs}g F${user.fats}g
    Allergies: ${user.allergies.join(', ')}
    Cuisine: ${user.regionalCuisine}
    Meals/day: ${user.mealsPerDay}
    
    Return JSON with daily meals and recipes.
    """;
  }
}
```

### 16.4 OFFLINE FUNCTIONALITY

#### Features Available Offline:
- View cached workout plans
- Log workouts (sync when online)
- Log meals (manual entry only, no scanning)
- View progress history
- Exercise library (cached)

#### Sync Strategy:
- Background sync every 5 minutes when online
- Conflict resolution: Latest timestamp wins
- Pending changes indicator in UI
- Manual "Sync Now" button

---

## 17. AI SAFETY & ETHICAL CONSIDERATIONS

### 17.1 Health & Safety Guardrails

#### Medical Disclaimers:
- Prominent disclaimer on first launch
- "Consult doctor before starting any fitness program"
- AI cannot diagnose conditions
- Emphasize app is for general wellness

#### Injury Prevention:
```
System Instruction to Gemini:
"When user reports pain:
1. ALWAYS recommend seeing healthcare professional
2. Suggest stopping the exercise immediately
3. Provide alternative exercises
4. Never minimize pain or injury concerns
5. Err on the side of caution"
```

#### Dangerous Request Detection:
- Extreme calorie deficits (<1000 cal/day)
- Excessive exercise (>2 hours daily for beginners)
- Requests for steroids/banned substances
- Eating disorder indicators

**Response:**
```
"I'm concerned about this request. For your safety, I cannot 
recommend [extreme approach]. Let's find a sustainable, healthy 
path to your goals. Would you like to talk to a healthcare 
professional? I can help you find one."
```

### 17.2 Mental Health Awareness

#### Body Image Sensitivity:
- No body shaming language
- Celebrate all body types
- Focus on health, not just aesthetics
- Diverse representation in imagery

#### Eating Disorder Detection:
```
Warning Signs:
- Extreme calorie restriction
- Excessive exercise after eating
- Obsessive food tracking
- Negative self-talk
- Rapid weight loss goals

AI Response:
"I notice some concerning patterns. Your health is most important. 
Have you considered talking to a healthcare professional? 
National Eating Disorder Helpline: [number]"
```

### 17.3 Data Privacy & Ethics

#### User Data Handling:
- **What's collected:** Profile, workouts, meals, AI conversations
- **What's NOT collected:** Unnecessary personal data, location (unless explicitly shared)
- **Data usage:** Personalization only
- **Never sold:** User data is never sold to third parties
- **Encryption:** All data encrypted at rest and in transit

#### AI Transparency:
- "Powered by AI" badges on AI-generated content
- Explain how AI works in Help section
- User control over AI features
- Ability to opt-out of AI features

#### Bias Mitigation:
- Diverse training data representation
- Regular bias audits
- Inclusive language
- Accommodations for disabilities
- Multiple body type considerations

---

## 18. MARKETING & GROWTH FEATURES

### 18.1 Referral Program

#### How It Works:
- User gets unique referral code
- Friend signs up with code
- Both get 1 month free premium
- Track referrals in-app

#### Viral Features:
- Share workout completion on social media
- Progress photo sharing (with privacy controls)
- Challenge friends to compete
- Shareable achievement badges

### 18.2 Content Marketing Integration

#### Blog/Articles (In-App):
- "10 Beginner Fitness Mistakes"
- "High-Protein Vegetarian Meals"
- "AI vs Personal Trainer: The Truth"
- SEO-optimized for app store

#### Video Tutorials:
- Exercise form videos
- Meal prep guides
- App tutorial series
- YouTube integration

---

## 19. FUTURE ENHANCEMENTS (ROADMAP)

### Phase 2 (6-12 months):
- [ ] AI form check via video analysis
- [ ] Wearable device integration (smartwatches)
- [ ] Live workout classes
- [ ] Nutrition barcode scanner
- [ ] Restaurant meal finder
- [ ] Grocery list with price comparison

### Phase 3 (12-18 months):
- [ ] Personal trainer marketplace
- [ ] Nutritionist consultations
- [ ] Telemedicine integration
- [ ] DNA-based personalization
- [ ] AR workout guidance
- [ ] Group workout rooms (virtual)

### Phase 4 (18-24 months):
- [ ] Corporate wellness programs
- [ ] Insurance partnerships
- [ ] Physical therapy integration
- [ ] Mental health features (meditation, stress)
- [ ] Sleep tracking & optimization
- [ ] Habit formation coaching

---

## 20. SUCCESS METRICS & KPIs

### User Engagement:
- Daily Active Users (DAU)
- Weekly Active Users (WAU)
- Average session duration: Target 15+ minutes
- Workout completion rate: Target 70%+
- Meal logging consistency: Target 60%+

### Health Outcomes:
- Average weight loss: 0.3-0.5 kg/week
- User-reported satisfaction: Target 4.5+/5
- Goal achievement rate: Target 40%+ reach goal
- 90-day retention: Target 35%+

### AI Performance:
- AI response accuracy (user feedback)
- Food scan accuracy: Target 85%+
- Workout plan satisfaction: Target 80%+
- AI chat engagement: Avg 5+ messages/day

### Business Metrics:
- Free to paid conversion: Target 5-10%
- Monthly recurring revenue (MRR)
- Customer acquisition cost (CAC)
- Lifetime value (LTV)
- Churn rate: Target <5%/month

---

## COMPREHENSIVE ONE-SHOT PROMPT FOR AI DEVELOPMENT

### Master Development Prompt:

```
Create a comprehensive AI-powered Fitness & Nutrition mobile application using Flutter and Gemini API with the following complete specifications:

## APP OVERVIEW
- Name: [Your App Name]
- Tagline: Your AI-Powered Fitness Journey
- Target Users: Fitness beginners to advanced, ages 18-65
- Monetization: Freemium model ($9.99/month premium)
- Platforms: iOS, Android (Flutter)
- Design: Modern, dark blue theme, minimalist, professional

## CORE TECHNOLOGY STACK
- Frontend: Flutter with BLoC pattern
- Backend: Firebase (Auth, Firestore, Storage)
- AI Engine: Google Gemini API (Text & Vision models)
- Analytics: Firebase Analytics
- Push Notifications: Firebase Cloud Messaging
- State Management: flutter_bloc
- Data Visualization: fl_chart
- Local Storage: shared_preferences

## COMPLETE FEATURE SET

### 1. AUTHENTICATION SYSTEM
- Email/password registration with validation
- Google Sign-In integration
- Password reset functionality
- Email verification
- Biometric authentication (fingerprint/face)
- Secure token storage
- Session management
- Auto-logout after 30 days inactivity

### 2. ONBOARDING FLOW (4 Screens)
- Splash screen with brand introduction
- Screen 1: AI Coach introduction
- Screen 2: Smart workout planning
- Screen 3: Intelligent nutrition
- Screen 4: 24/7 AI support
- Swipeable navigation with skip option
- Progress indicators
- Store completion flag locally

### 3. USER PROFILE SETUP (5-Step Wizard)
**Step 1 - Basic Info:**
- Name, age (13-100), gender, profile photo
- Validation and auto-save

**Step 2 - Body Metrics:**
- Height (cm/ft-in toggle), current weight, target weight
- BMI auto-calculation
- Body type selection (visual)
- Realistic goal validation

**Step 3 - Fitness Profile:**
- Primary goal (fat loss, muscle gain, maintenance, endurance, flexibility, general health)
- Fitness level (beginner, intermediate, advanced, athlete)
- Activity level (5 options)
- Available equipment (multi-select with custom entry)
- Workout location and duration preference

**Step 4 - Nutrition Profile:**
- Dietary preference (vegetarian, non-veg, vegan, pescatarian, keto, paleo)
- Regional cuisine (auto-detect + manual)
- Food allergies (common + custom)
- Foods to avoid
- Meals per day (2-6 slider)
- Water intake goal (auto-calculated, adjustable)

**Step 5 - Health & Lifestyle:**
- Medical conditions checklist
- Current medications (yes/no with details)
- Injuries/limitations (free text)
- Average sleep hours
- Stress level (1-10 scale)
- Smoking/alcohol habits

**On Completion:**
- Send complete profile to Gemini for analysis
- Generate personalized welcome message
- Calculate TDEE and calorie targets
- Create initial workout plan
- Generate first week meal plan
- Save to Firestore
- Navigate to Home Dashboard

### 4. HOME DASHBOARD (Central Hub)
**Header:**
- Personalized greeting with time of day
- Current date
- Daily AI-generated motivational quote
- Streak counter with fire icon

**Today's Overview Card:**
- Workout status with progress bar
- "Start Workout" CTA button
- Rest day indicator if applicable

**Nutrition Status:**
- Circular calorie chart (consumed/target/remaining)
- Mini macro breakdown bars (protein, carbs, fats)
- "Log Meal" quick action

**Water Intake:**
- 8 glass icons (tap to mark consumed)
- Progress counter
- Visual filling animation

**Steps Counter:**
- Integration with pedometer
- Progress bar with goal
- Daily step count

**AI Suggestion Card:**
- Dynamic recommendations based on:
  * Time of day
  * Recent activity
  * Progress patterns
  * Weather (if location enabled)
- Actionable 1-2 sentence suggestions

**Quick Actions Grid:**
- Start Workout (large primary)
- Scan Food (camera)
- Log Meal
- Ask AI Coach (chat)
- View Progress
- Water Reminder

**Weekly Summary:**
- Workouts completed (X/X)
- Average daily calories
- Weight change with trend arrow
- AI-calculated consistency score

**Bottom Navigation:**
- Home, Workouts, Nutrition, Progress, Profile

**Functional Logic:**
- Pull to refresh
- Real-time updates every 5 minutes
- Background sync
- Cached data for offline viewing

### 5. AI WORKOUT PLANNER
**Weekly View:**
- Calendar grid with 7 days
- Each day card shows:
  * Workout name
  * Duration
  * Exercise count
  * Difficulty badge
  * Status (scheduled/completed/skipped)
  * Rest day badge

**Workout Generation (Gemini API):**
```
System Prompt:
"Generate a 7-day personalized workout plan in JSON format for a user with:
- Goal: [fat loss/muscle gain/etc]
- Fitness Level: [beginner/intermediate/advanced]
- Equipment: [list]
- Duration: [30-60 minutes]
- Days per week: [3-6]
- Injuries/Limitations: [list]
- Previous week performance data: [completion rate, feedback]

Include: warm-up, main exercises (name, sets, reps, rest, notes, alternatives), cool-down, weekly focus, tips.

Apply progressive overload: Week 1-2 foundation, Week 3-4 increase volume, Week 5-6 increase intensity, Week 7-8 peak then deload.

Return structured JSON."
```

**Exercise Library:**
- Searchable database
- Filters (muscle group, equipment, difficulty)
- Each exercise: GIF demo, instructions, muscles targeted, alternatives
- "Add to Custom Workout" option
- "Ask AI about exercise" button

**Plan Regeneration:**
- Auto-generate weekly on Sundays
- Adaptive difficulty based on performance
- Manual "Get Alternative Plan" option

### 6. WORKOUT SESSION SCREEN
**Layout:**
- Header: Workout title, exercise progress (3/6), timer
- Large exercise name
- Looping GIF/video demonstration
- Current set display (Set 2 of 3)
- Target reps/time
- Rest timer with countdown

**Controls:**
- "Set Completed" button (logs reps/weight)
- Quick number picker for reps
- Weight input (remembers last used)
- "Skip Exercise" with reason selection
- "Need Help?" AI chat overlay

**Expandable Bottom Sheet:**
- Step-by-step instructions
- Key form points (3-4 bullets)
- Common mistakes
- Exercise history (last performance, PR)
- Muscle map visualization

**Workout Flow:**
1. Pre-workout summary (equipment check)
2. 5-minute guided warm-up (skippable)
3. For each exercise:
   - 5-second preparation countdown
   - User performs exercise
   - Tap "Set Completed"
   - Quick reps/weight log
   - Auto-start rest timer
   - Motivational message during rest
   - Next exercise preview at 10s
4. Post-workout cool-down (5 minutes)
5. Summary screen with:
   - Completion confetti
   - Total time, volume, calories
   - Personal records highlighted
   - AI feedback message
   - Share options

**AI Adaptive Features:**
- Real-time form cues displayed
- Struggle detection (long rests, skipped exercises)
- Weight adjustment suggestions
- Alternative exercise recommendations
- Performance comparison to previous workout

**Integrations:**
- Music (Spotify/Apple Music)
- Smartwatch heart rate
- Optional video recording for form review

### 7. AI NUTRITION PLANNER
**Daily Nutrition Dashboard:**
- Date selector (swipeable)
- Large calorie ring chart
- Color-coded: green (target ±100), yellow (±200), red (>200)
- Three macro progress bars (protein, carbs, fats)
- Today's meals section:
  * Breakfast, snack, lunch, snack, dinner
  * Each shows: name, time, calories, macros, thumbnail
  * Edit/delete options
  * "Log" button for empty meals
- Water intake tracker (tap glasses to fill)
- Supplement checklist

**AI Meal Plan Generation (Gemini API):**
```
Generate a [duration] meal plan for:
- Goal: [fat loss/muscle gain/maintenance]
- Target Calories: [number] (deficit/surplus of [number])
- Macros: Protein [g] ([%]), Carbs [g] ([%]), Fats [g] ([%])
- Diet: [vegetarian/non-veg/vegan/etc]
- Allergies: [list]
- Dislikes: [list]
- Regional Preference: [cuisine type]
- Meals Per Day: [number]
- Budget: [economy/standard/premium]
- Cooking Skill: [simple/moderate/advanced]
- Previous favorites: [list]

Return JSON with:
- Daily meal plans (breakfast, lunch, dinner, snacks)
- Each meal: name, description, calories, macros, ingredients, recipe (prep time, cook time, steps), alternatives
- Weekly shopping list with quantities and cost
- Meal prep guide

Ensure calorie and macro accuracy within 5%.
```

**Meal Plan Display:**
- Weekly grid view
- Daily detailed view with expandable meal cards
- Recipe mode with step-by-step
- Swap meal feature (3 alternatives)
- Adjust portion slider
- Leftover planning suggestions
- Batch cooking identification
- Shopping list (categorized, checkable, exportable)
- Add to favorites
- Share recipe

**Food Logging:**
- Search food database (recent, favorites, custom)
- Serving size selector
- Quantity adjuster
- Real-time macro calculation
- Manual food creation
- Quick add calories only

### 8. AI FOOD SCANNER (Unique Feature)
**Camera Interface:**
- Live camera view with guides
- Capture button
- Gallery upload option
- Flash and focus controls
- "Tips for best results" overlay

**Scanning Process:**
1. Capture food image
2. Display "Analyzing..." animation
3. Send image to Gemini Vision API
4. Receive food identification and nutrition estimate
5. Show results screen

**Gemini Vision Prompt:**
```
Analyze this food image:
1. Identify all visible food items
2. Estimate portion size for each (grams, serving size)
3. Calculate nutritional values per item
4. Provide confidence scores
5. Suggest meal type (breakfast/lunch/dinner)
6. Note if healthy/balanced

User context: [diet type], [tracking goal]

Return JSON with:
- foods_detected: [{name, portion_size, grams, confidence, calories, protein, carbs, fats}]
- total_meal: {calories, protein, carbs, fats}
- meal_type_suggestion
- health_notes
```

**Results Screen:**
- List of detected foods with confidence badges
- Edit portions/weights
- Add/remove items manually
- Total nutrition summary
- "Log This Meal" button
- "Retake Photo" option
- Save for future reference

**Accuracy Features:**
- Request multiple angles if confidence <80%
- "Does this look right?" confirmation
- Learn from user corrections
- Common food database for quick matching

### 9. AI FITNESS CHATBOT
**Interface:**
- Clean messaging UI
- User: right-aligned blue bubbles
- AI: left-aligned gray bubbles
- Typing indicator (bouncing dots)
- Timestamps
- Date separators

**Header:**
- AI avatar (animated)
- "Online" status
- "Your AI Fitness Coach" title
- Settings (chat preferences)

**Input Area:**
- Text input: "Ask me anything..."
- Send button
- Microphone (voice input)
- Attachment (images for form check, food scan)
- Quick chips: "Workout advice", "Nutrition tips", "Motivate me", "Exercise alternative"

**AI Capabilities:**

1. **Workout Advice:**
   - Exercise form tips
   - Alternative exercises
   - Injury management (always recommend doctor)
   - Program modifications
   - Recovery advice

2. **Nutrition Guidance:**
   - Food substitutions
   - Meal ideas
   - Calorie/macro explanations
   - "Can I eat X?" questions
   - Restaurant ordering tips

3. **Motivation:**
   - Encouraging messages
   - Progress reminders
   - Plateau breakthrough advice
   - Habit building strategies

4. **Accountability:**
   - Check-ins
   - Challenge user gently
   - Celebrate wins
   - Address concerns

**AI Context Awareness:**
- Full user profile access
- Recent workout history
- Current nutrition data
- Previous chat history
- Time of day
- User's typical schedule

**Gemini Chat Prompt Template:**
```
You are an AI fitness coach. User profile: [complete profile data].

Recent context:
- Last workout: [date, type, completion]
- Today's calories: [consumed/target]
- Current goal progress: [metrics]
- Previous conversation: [last 5 messages]

User message: [user's question]

Respond as a knowledgeable, supportive, motivational fitness coach. Be:
- Encouraging but realistic
- Scientific but accessible
- Brief (under 150 words unless detailed explanation needed)
- Safety-conscious (recommend doctor for pain/injury)
- Personalized to their goal and level

Never:
- Diagnose medical conditions
- Recommend dangerous practices
- Be judgmental
- Promise unrealistic results
- Recommend steroids/banned substances
```

**Safety Features:**
- Auto-detect concerning requests
- Eating disorder warning signs
- Pain/injury→always suggest doctor
- Extreme diet requests→discourage
- Built-in disclaimers

### 10. PROGRESS & ANALYTICS
**Overview Dashboard:**
- Time range selector (week/month/3mo/year/all)
- Export data button
- Multiple tabs

**Weight Tracking:**
- Line graph with data points
- Trend line (linear regression)
- Target weight line (dotted)
- Color zones (healthy, plateau, concerning)
- Stats cards:
  * Starting weight
  * Current weight
  * Goal weight
  * Total lost/gained
  * Remaining
  * Average weekly change
  * AI-calculated ETA to goal
- Log weight button
- Body measurements (chest, waist, hips, arms, thighs)
- Progress photos (front/side/back with date stamps)
- Before/after comparison slider

**Workout Analytics:**
- Calendar heatmap (workout completion)
- Streak counter (current & longest)
- Completion stats (this month/year)
- Volume progression (bar chart by week)
- Exercise-specific graphs (max weight over time)
- Personal records highlighted
- Average duration trends
- Rest time optimization

**Nutrition Analytics:**
- Weekly calorie bar chart (target line, color-coded adherence)
- Macro trend stacked area chart
- Macro adherence percentages
- Meal logging consistency
- Logging streaks
- Water intake trends
- Sleep correlation (if tracked)

**AI Progress Report (Auto-Generated Weekly):**
```
Gemini Prompt:
"Analyze user's week:
- Workouts: [completed/planned] with adherence [%]
- Weight: [current] (change: [+/-])
- Calories: avg [number]/day (target: [number])
- Macros: actual vs target
- Volume lifted: [kg] (change from last week)
- Sleep: avg [hours]
- Steps: avg [count]/day

Generate motivational progress report (200 words) including:
1. Biggest achievement this week
2. Most improved area
3. Focus for next week
4. Personalized encouragement
5. Specific actionable advice

Tone: Supportive, celebratory, motivating."
```

**Milestones & Achievements:**
- Auto-trigger celebrations:
  * Lost 5kg, 10kg, etc.
  * 50, 100, 500 workouts
  * 30, 90, 365-day streaks
  * Volume milestones
  * Meal logging milestones
- Confetti animation
- Achievement badge
- Shareable card
- Points awarded

**Predictions:**
- AI-powered goal date prediction
- Confidence level
- What could accelerate/slow progress
- Plateau warnings
- Based on current trends

### 11. SMART REMINDERS
**Notification Types:**
1. **Workout Reminders:**
   - Customizable time
   - 30-minute advance warning
   - Snooze options (15/30/60 min)
   - AI-optimized timing (learns user behavior)

2. **Meal Reminders:**
   - Breakfast, lunch, dinner times
   - "Don't forget to log!" 1 hour after
   - Pre-meal prep reminders

3. **Water Reminders:**
   - Every 2 hours (customizable)
   - Auto-pause during sleep hours
   - Celebration at goal completion

4. **Weigh-In:**
   - Weekly same day/time
   - Consistency importance message

5. **Motivational:**
   - Random inspirational quotes
   - Progress milestones
   - Streak alerts
   - "Don't break your streak!" warnings

**Smart Features:**
- Adaptive timing (learn user patterns)
- Context-aware (don't disturb during meetings, at gym)
- Behavior-based frequency (reduce if user self-compliant)
- Action-oriented (swipe to complete)

**Settings:**
- Toggle each type on/off
- Customize times
- Set quiet hours
- Notification sounds

### 12. SETTINGS & CUSTOMIZATION
**Profile Settings:**
- Edit photo, name, age, gender
- Update goals anytime
- Change activity level
- Modify equipment
- Update diet preferences
- Edit allergies
- Adjust targets

**App Preferences:**
- Theme (dark/light/auto)
- Color accent selection
- Font size
- Units (metric/imperial)
- Language selection

**Notifications:**
- Master toggle
- Individual notification types
- Quiet hours
- Sound selection

**AI Control:**
- AI personality (formal/friendly/motivational/humorous)
- Response length (brief/detailed)
- Suggestion frequency (minimal/moderate/maximum)
- Reset AI (clear history, regenerate plans)
- AI data usage transparency
- Export AI conversation history

**Data & Privacy:**
- Export all data (JSON/PDF/CSV)
- Delete specific data (workouts/meals/photos)
- Delete account
- Privacy settings (profile visibility)
- Who can see progress
- Anonymous mode

**Integrations:**
- Google Fit / Apple Health
- Spotify / Apple Music
- Calendar sync
- Fitbit / Garmin / Strava

### 13. COMMUNITY & SOCIAL (Optional)
**Community Feed:**
- Workout completions
- Progress photos
- Meal shares
- Achievements
- Like and comment
- Privacy controls (public/friends/private)

**Challenges:**
- Join 30-day challenges
- Workout challenges
- Step challenges
- Leaderboards
- Badges for completion
- Create custom challenges (premium)

**Friends:**
- Add friends (search/QR/contacts)
- View friends' activity
- Send encouragement
- Compare progress (mutual consent)
- Workout together sync

### 14. PREMIUM FEATURES
**Free Tier:**
- AI workout plans (1 week)
- Daily meal suggestions
- Food scanner (5/day)
- AI chat (10 messages/day)
- Basic progress tracking
- Ads

**Premium ($9.99/month or $79.99/year):**
- Unlimited AI access
- 4-week workout programs
- Monthly meal plans
- Unlimited food scans
- Advanced analytics
- Predictions
- Priority AI responses
- Multiple plan variations
- Custom program builder
- Supplement recommendations
- Ad-free
- Premium badge
- Early access features

### 15. GAMIFICATION
**Levels:**
- Novice → Beginner → Intermediate → Advanced → Elite
- Based on workouts completed

**Badges:**
- First Workout
- 7/30/100-day streaks
- Early Bird / Night Owl
- Meal Prep Master
- Hydration Hero
- Weight milestones
- Volume milestones

**Points System:**
- Complete workout: +100
- Log meal: +20
- Hit water goal: +10
- Streak bonuses
- Redeem for: premium trial, badges, themes

### 16. TECHNICAL REQUIREMENTS
**Firebase Setup:**
- Authentication (email, Google)
- Firestore database structure:
  ```
  users/{userId}/
    - profile
    - settings
    - workouts/ (subcollection)
    - meals/ (subcollection)
    - progress/ (subcollection)
    - ai_plans/ (subcollection)
    - achievements/ (subcollection)
  ```
- Storage for photos
- Cloud Functions for scheduled tasks
- Analytics
- Cloud Messaging for push notifications

**Gemini API Integration:**
- API key management (.env file)
- Text model for chat, plans, insights
- Vision model for food scanning
- Prompt templates
- Error handling
- Caching strategy (24 hours)
- Rate limiting
- Fallback to cached data

**State Management:**
- BLoC pattern throughout
- Repository pattern for data
- Clean architecture
- Proper error handling
- Loading states
- Offline capabilities

**Offline Functionality:**
- Cache workout plans
- Log workouts offline (sync later)
- Manual meal logging
- View progress history
- Exercise library cached
- Pending changes indicator
- Manual "Sync Now"

**Performance Optimization:**
- Image compression
- Lazy loading
- Pagination
- Debounced search
- Optimized rebuilds
- Asset caching

**Security:**
- Secure token storage
- Data encryption
- Firestore security rules
- API key protection
- Input validation
- XSS protection

### 17. ETHICAL & SAFETY CONSIDERATIONS
**Health Disclaimers:**
- Prominent disclaimer on first launch
- "Consult doctor" messaging
- App is for general wellness
- Not medical advice

**AI Safety Guards:**
- Never diagnose conditions
- Always recommend doctor for pain/injury
- Detect extreme diets (under 1000 cal/day)
- Detect excessive exercise
- Eating disorder warning signs
- Dangerous substance requests→decline

**Mental Health:**
- No body shaming language
- Celebrate all body types
- Focus on health, not just aesthetics
- Diverse imagery
- Positive reinforcement

**Data Privacy:**
- Clear privacy policy
- Explain what data is collected
- How AI uses data
- Never sell data
- Encryption
- User control over data

**Bias Mitigation:**
- Diverse representations
- Inclusive language
- Disability accommodations
- Multiple body type support
- Regular bias audits

### 18. ANALYTICS & KPIs
**Track:**
- DAU / WAU / MAU
- Session duration
- Workout completion rate
- Meal logging consistency
- AI chat engagement
- Food scan accuracy
- Free to paid conversion
- Churn rate
- User satisfaction
- Goal achievement rate
- 90-day retention

### 19. FUTURE ROADMAP
**Phase 2:**
- AI video form analysis
- Wearable integration
- Live classes
- Barcode scanner
- Restaurant finder

**Phase 3:**
- Trainer marketplace
- Nutritionist consultations
- DNA personalization
- AR workout guidance
- Group workouts

**Phase 4:**
- Corporate wellness
- Insurance partnerships
- Physical therapy
- Mental health features
- Sleep optimization

## IMPLEMENTATION INSTRUCTIONS

1. **Setup Project:**
   - Initialize Flutter project
   - Configure Firebase
   - Set up folder structure (features/core/data/domain/presentation)
   - Install dependencies

2. **Build Core:**
   - Theme and constants
   - Reusable widgets
   - Utilities and helpers
   - API services (Gemini, Firebase)

3. **Feature Development Order:**
   a. Authentication (login, register, password reset)
   b. Onboarding (splash, intro screens)
   