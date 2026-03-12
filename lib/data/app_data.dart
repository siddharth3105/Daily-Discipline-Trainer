import '../models/models.dart';

// ── Exercise categories ─────────────────────────────────────────────────────
class ExerciseCategory {
  final String key, label, emoji;
  final List<String> exercises;
  final int color;
  final String icon;
  const ExerciseCategory({required this.key, required this.label, required this.emoji, required this.exercises, required this.color, required this.icon});
}

const weekSchedule = ['hiit','bodyweight','strength','flex','hiit','height','rest'];

const exerciseCategories = [
  ExerciseCategory(key:'hiit',       label:'HIIT Cardio',    emoji:'⚡', exercises:['Jumping Jacks','Burpee','Mountain Climbers'], color:0xFFFF3B30, icon:'⚡'),
  ExerciseCategory(key:'bodyweight', label:'Bodyweight',     emoji:'🤸', exercises:['Push-Up','Pull-Up','Plank'], color:0xFF007AFF, icon:'🤸'),
  ExerciseCategory(key:'strength',   label:'Strength',       emoji:'🏋',  exercises:['Barbell Squat','Deadlift','Bench Press','Overhead Press'], color:0xFFFF9500, icon:'🏋'),
  ExerciseCategory(key:'flex',       label:'Flexibility',    emoji:'🧘', exercises:['Hip Flexor Stretch','Cat-Cow Stretch'], color:0xFF30D158, icon:'🧘'),
  ExerciseCategory(key:'height',     label:'Height & Spine', emoji:'📏', exercises:['Hanging Decompression','Cobra Pose','Cat-Cow Stretch'], color:0xFFBF5AF2, icon:'📏'),
];

final exercisesByName = <String,Exercise>{
  'Jumping Jacks': const Exercise(name:'Jumping Jacks',category:'hiit',calories:8,sets:4,reps:'30 reps',animationType:'jumpjax',muscle:'Full Body',tip:'Land softly on balls of feet to protect joints.',steps:['Stand with feet together, arms at sides','Jump feet apart while raising arms overhead','Jump back to start','Repeat at a steady rhythm'],mistakes:['Locking knees on landing','Looking down instead of forward']),
  'Burpee': const Exercise(name:'Burpee',category:'hiit',calories:12,sets:3,reps:'15 reps',animationType:'burpee',muscle:'Full Body',tip:'Keep your core tight throughout the entire movement.',steps:['Stand upright','Drop hands to floor, jump feet back into plank','Perform a push-up (optional)','Jump feet to hands, then explosively jump up with arms overhead'],mistakes:['Sagging hips in plank','Landing flat-footed on the jump']),
  'Mountain Climbers': const Exercise(name:'Mountain Climbers',category:'hiit',calories:9,sets:4,reps:'30 sec',animationType:'mountainclimber',muscle:'Core & Cardio',tip:'Drive knees toward chest as fast as control allows.',steps:['Start in a high plank position','Alternate driving each knee toward chest','Maintain neutral spine','Keep hips level — don\'t bounce'],mistakes:['Raising hips too high','Losing plank position as fatigue sets in']),
  'Push-Up': const Exercise(name:'Push-Up',category:'bodyweight',calories:6,sets:4,reps:'20 reps',animationType:'pushup',muscle:'Chest, Triceps, Shoulders',tip:'Lower your chest all the way to the ground for full range.',steps:['Set up in a high plank: hands shoulder-width apart','Lower your chest toward the floor','Keep elbows at 45° from torso','Push back to start — squeeze chest at top'],mistakes:['Flaring elbows too wide','Sagging or piking hips','Incomplete range of motion']),
  'Pull-Up': const Exercise(name:'Pull-Up',category:'bodyweight',calories:7,sets:3,reps:'10 reps',animationType:'pullup',muscle:'Back, Biceps',tip:'Start from a dead hang each rep for full lat activation.',steps:['Hang from a bar with a pronated (overhand) grip','Depress scapulae before pulling','Drive elbows toward hips','Chin clears bar, lower with full control'],mistakes:['Kipping without foundations','Partial range of motion','Shrugging shoulders at the top']),
  'Plank': const Exercise(name:'Plank',category:'bodyweight',calories:4,sets:3,reps:'60 sec',animationType:'plank',muscle:'Core, Shoulders',tip:'Squeeze your glutes hard — it prevents hip sag automatically.',steps:['Forearms on floor, elbows under shoulders','Form a straight line from head to heels','Brace abs as if about to be punched','Hold and breathe'],mistakes:['Sagging hips','Raised hips / piking','Forgetting to breathe']),
  'Barbell Squat': const Exercise(name:'Barbell Squat',category:'strength',calories:10,sets:4,reps:'10 reps',animationType:'squat',muscle:'Quads, Glutes, Hamstrings',tip:'Drive your knees out in line with your toes throughout.',steps:['Bar on upper traps, feet shoulder-width','Brace core, unlock hips and knees simultaneously','Descend until thighs are parallel (or below)','Drive through heels, extend hips and knees to stand'],mistakes:['Knees caving inward','Butt wink at bottom','Heels rising off ground']),
  'Deadlift': const Exercise(name:'Deadlift',category:'strength',calories:12,sets:4,reps:'8 reps',animationType:'deadlift',muscle:'Posterior Chain',tip:'Think "push the floor away" rather than "pull the bar up".',steps:['Feet hip-width, bar over mid-foot','Hip hinge to grip bar just outside legs','Neutral spine, chest tall, lats engaged','Push floor away, drive hips forward at lockout'],mistakes:['Rounding lower back','Bar drifting away from body','Jerking the bar off the floor']),
  'Bench Press': const Exercise(name:'Bench Press',category:'strength',calories:8,sets:4,reps:'10 reps',animationType:'benchpress',muscle:'Chest, Triceps, Shoulders',tip:'Retract and depress your shoulder blades before every set.',steps:['Lie on bench, grip slightly wider than shoulders','Unrack, lower bar to lower chest with control','Touch chest lightly (no bounce)','Press explosively back to start'],mistakes:['Flared elbows','Lifting glutes off bench','Bar path too high (toward neck)']),
  'Overhead Press': const Exercise(name:'Overhead Press',category:'strength',calories:8,sets:4,reps:'10 reps',animationType:'ohp',muscle:'Shoulders, Triceps',tip:'Push your head through the window as the bar clears your face.',steps:['Bar at shoulder height, grip just outside shoulders','Brace core, tuck chin','Press straight up — bar travels slightly back once past face','Lock out fully at top, lower under control'],mistakes:['Excessive lumbar arch','Bar path drifting forward','Incomplete lockout']),
  'Hip Flexor Stretch': const Exercise(name:'Hip Flexor Stretch',category:'flex',calories:2,sets:3,reps:'45 sec/side',animationType:'hipstretch',muscle:'Hip Flexors, Psoas',tip:'Actively tuck your pelvis to deepen the stretch.',steps:['Kneel on one knee, other foot forward','Sink hips forward and down','Reach same-side arm overhead','Hold and breathe deeply into the stretch'],mistakes:['Arching lower back instead of stretching hip','Not staying upright in torso']),
  'Cat-Cow Stretch': const Exercise(name:'Cat-Cow Stretch',category:'flex',calories:2,sets:3,reps:'10 rounds',animationType:'catcow',muscle:'Spine, Core',tip:'Move with your breath — exhale on cat, inhale on cow.',steps:['On hands and knees, wrists under shoulders','Cat: round spine toward ceiling, tuck chin','Cow: drop belly, lift chest and tailbone','Flow smoothly with each breath'],mistakes:['Moving too fast without breathing','Only moving in lumbar, not thoracic spine']),
  'Hanging Decompression': const Exercise(name:'Hanging Decompression',category:'height',calories:2,sets:3,reps:'30 sec',animationType:'hang',muscle:'Spine, Lats, Grip',tip:'Let gravity do the work — relax everything below your shoulders.',steps:['Grip an overhead bar at arms length','Relax your lower body completely','Let spine elongate naturally','Breathe slowly and hold'],mistakes:['Gripping too hard (prevents relaxation)','Engaging core (defeats purpose)']),
  'Cobra Pose': const Exercise(name:'Cobra Pose',category:'height',calories:2,sets:3,reps:'45 sec',animationType:'cobra',muscle:'Spine, Abs (stretch), Chest',tip:'Use your back muscles to lift, not just your arms.',steps:['Lie face down, hands under shoulders','Press tops of feet into floor','On inhale, lift chest using back muscles','Shoulders away from ears, gaze forward or slightly up'],mistakes:['Compressing lower back by bending too far','Lifting with arms only, not back muscles']),
};

// ── Badges ──────────────────────────────────────────────────────────────────
final allBadges = [
  BadgeModel(id:'first_rep', icon:'🎯', name:'First Rep', desc:'Checked first exercise', check:(s)=>s.totalExercises>=1),
  BadgeModel(id:'streak3',   icon:'🔥', name:'On Fire',   desc:'3-day streak',           check:(s)=>s.streak>=3),
  BadgeModel(id:'streak7',   icon:'⚡', name:'Committed', desc:'7-day streak',           check:(s)=>s.streak>=7),
  BadgeModel(id:'streak30',  icon:'🏆', name:'Legend',    desc:'30-day streak',          check:(s)=>s.streak>=30),
  BadgeModel(id:'pts100',    icon:'💯', name:'Century',   desc:'100 points earned',      check:(s)=>s.totalPoints>=100),
  BadgeModel(id:'pts500',    icon:'⭐', name:'Star',      desc:'500 points earned',      check:(s)=>s.totalPoints>=500),
  BadgeModel(id:'pts1000',   icon:'🌟', name:'Superstar', desc:'1000 points earned',     check:(s)=>s.totalPoints>=1000),
  BadgeModel(id:'hydrated',  icon:'💧', name:'Hydrated',  desc:'Drank 8 glasses',        check:(s)=>s.maxWater>=8),
  BadgeModel(id:'diet_week', icon:'🥗', name:'Diet Dialed',desc:'Logged 7 food entries', check:(s)=>s.dietDays>=7),
  BadgeModel(id:'sessions5', icon:'🏅', name:'Consistent',desc:'5 sessions done',        check:(s)=>s.completedSessions>=5),
  BadgeModel(id:'sessions20',icon:'💎', name:'Dedicated', desc:'20 sessions done',       check:(s)=>s.completedSessions>=20),
  BadgeModel(id:'perfect5',  icon:'✨', name:'Perfectionist',desc:'5-day workout streak',check:(s)=>s.streak>=5),
];

// ── Motivational quotes ─────────────────────────────────────────────────────
const motivationalQuotes = [
  "Discipline is the bridge between goals and accomplishment. — Jim Rohn",
  "The pain you feel today will be the strength you feel tomorrow.",
  "Success is the sum of small efforts, repeated day in and day out.",
  "Your body can stand almost anything. It's your mind you have to convince.",
  "Don't wish for it. Work for it.",
  "Champions aren't made in gyms. They're made from something inside them.",
  "Every rep counts. Every meal matters. Every day adds up.",
  "You don't have to be extreme, just consistent.",
  "Train insane or remain the same.",
  "The only bad workout is the one that didn't happen.",
  "Sweat is just fat crying.",
  "Take care of your body. It's the only place you have to live.",
  "Motivation gets you started. Discipline keeps you going.",
  "Fall in love with the process and the results will come.",
  "Strong is the new skinny.",
  "You are one workout away from a good mood.",
  "Do something today that your future self will thank you for.",
  "Believe in yourself and all that you are.",
  "The harder the battle, the sweeter the victory.",
  "Strive for progress, not perfection.",
  "Your only competition is who you were yesterday.",
  "Be stronger than your excuses.",
  "Eat clean. Train dirty.",
  "Hustle for that muscle.",
  "It never gets easier. You just get better.",
  "The body achieves what the mind believes.",
  "Push yourself because no one else is going to do it for you.",
  "Wake up. Work out. Be a better person.",
  "No pain, no gain. Shut up and train.",
  "Make yourself proud.",
  "You don't find the will to win, you bring it.",
];

// ── Diet plans ──────────────────────────────────────────────────────────────
const dietPlans = {
  'muscle': DietPlan(label:'💪 Muscle Gain', goalCalories:2800, meals:[
    MealItem(time:'7:00 AM', name:'Power Breakfast', foods:'5 egg omelette + 2 whole wheat toast + banana + milk', cal:650, protein:42, carbs:72, fat:18),
    MealItem(time:'10:30 AM',name:'Mid-Morning Shake',foods:'Whey protein shake + oats + peanut butter + almond milk', cal:420, protein:35, carbs:40, fat:12),
    MealItem(time:'1:00 PM', name:'Lean Lunch',       foods:'200g chicken breast + 1 cup brown rice + salad + olive oil', cal:680, protein:52, carbs:65, fat:16),
    MealItem(time:'4:00 PM', name:'Pre-Workout',      foods:'2 bananas + handful almonds + 1 scoop creatine + water', cal:350, protein:8, carbs:52, fat:12),
    MealItem(time:'7:30 PM', name:'Post-Workout Meal',foods:'200g salmon + 1.5 cup quinoa + roasted vegetables', cal:580, protein:48, carbs:55, fat:14),
    MealItem(time:'10:00 PM',name:'Night Protein',    foods:'1 cup Greek yogurt + casein protein + mixed nuts', cal:320, protein:38, carbs:18, fat:10),
  ], tips:['Eat every 3–4 hours to maximise muscle protein synthesis','Consume protein within 30 minutes post-workout','Aim for 2g protein per kg of bodyweight daily','Prioritise sleep — 90% of muscle growth happens during recovery']),
  'fatloss': DietPlan(label:'🔥 Fat Loss', goalCalories:1900, meals:[
    MealItem(time:'7:00 AM', name:'Light Breakfast',  foods:'3 scrambled eggs + 1 toast + black coffee + orange', cal:340, protein:25, carbs:28, fat:14),
    MealItem(time:'10:00 AM',name:'Morning Snack',    foods:'Apple + 20g almonds + green tea', cal:200, protein:5, carbs:26, fat:10),
    MealItem(time:'1:00 PM', name:'Lean Lunch',       foods:'150g grilled chicken + large salad + lemon dressing', cal:380, protein:42, carbs:22, fat:12),
    MealItem(time:'4:00 PM', name:'Pre-Workout',      foods:'1 banana + black coffee', cal:120, protein:1, carbs:30, fat:0),
    MealItem(time:'7:30 PM', name:'Dinner',           foods:'150g tilapia + steamed broccoli + sweet potato', cal:480, protein:44, carbs:48, fat:8),
    MealItem(time:'9:00 PM', name:'Evening Snack',    foods:'Casein protein + cucumber slices', cal:180, protein:28, carbs:8, fat:2),
  ], tips:['Never skip breakfast — it regulates hunger hormones all day','Drink 2–3L water daily to reduce appetite and boost metabolism','High-volume, low-calorie foods (salads, veggies) keep you full','Cardio fasted in the morning maximises fat oxidation']),
  'height': DietPlan(label:'📏 Height Growth', goalCalories:2400, meals:[
    MealItem(time:'7:00 AM', name:'Growth Breakfast', foods:'4 eggs + milk + spinach smoothie + banana', cal:540, protein:38, carbs:58, fat:16),
    MealItem(time:'10:30 AM',name:'Calcium Boost',    foods:'Greek yogurt + almonds + fortified orange juice', cal:380, protein:20, carbs:42, fat:14),
    MealItem(time:'1:00 PM', name:'Protein Lunch',    foods:'200g lean beef + brown rice + mixed vegetables', cal:620, protein:48, carbs:60, fat:14),
    MealItem(time:'4:00 PM', name:'Pre-Training',     foods:'Boiled eggs + whole fruit + zinc supplement', cal:280, protein:22, carbs:30, fat:8),
    MealItem(time:'7:30 PM', name:'Recovery Dinner',  foods:'200g tuna + pasta + milk + broccoli', cal:560, protein:52, carbs:58, fat:10),
    MealItem(time:'10:00 PM',name:'Sleep Nutrition',  foods:'Warm milk + melatonin-rich foods (cherries)', cal:220, protein:12, carbs:30, fat:6),
  ], tips:['Get 8–10 hours of sleep — HGH is released in deep sleep phases','Include calcium (milk, yogurt) + Vitamin D (sunlight) daily','Hang decompression exercises daily to lengthen spinal discs','Avoid carbonated drinks which leach calcium from bones']),
};
