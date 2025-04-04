import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("credentials.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def firebase_users():
    users_ref = db.collection("users")
    docs = users_ref.get()

    formatted_data = {}

    for doc in docs:
        user_id = doc.id
        user_data = doc.to_dict()

        formatted_data[user_id] = {
            "skills": {skill["name"].strip().lower(): skill["level"].strip().lower() for skill in user_data.get("skills", [])}
        }
    
    return formatted_data

def firebase_requests():
    requests_ref = db.collection("requests")
    docs = requests_ref.get()

    formatted_data = {}

    for doc in docs:
        user_data = doc.to_dict()

        if user_data.get("status") != "pending":
            continue  

        user_id = doc.id  # Using document ID as request identifier
        requester_id = user_data.get("userId")  # The user who created the request
        skills = [skill.strip().lower() for skill in user_data.get("skillRequired", [])]
        skill_levels = [level.strip().lower() for level in user_data.get("skillLevelRequired", [])]

        formatted_data[user_id] = {
            "request_user_id": requester_id,  # Store requester's ID
            "skills": dict(zip(skills, skill_levels))
        }

    return formatted_data

def compare(request, users):
    skills_match_data = {}

    request_skills = request["skills"]
    requester_id = request["request_user_id"]  # Exclude this user
    found_n_n_match = False  

    for user_id, user_data in users.items():
        if user_id == requester_id:  # Skip the request creator
            continue  

        user_skills = user_data["skills"]
        matched_skills = sum(1 for skill, level in request_skills.items() if skill in user_skills and user_skills[skill] == level)
        total_requested = len(request_skills)

        if matched_skills == 0:
            continue  # Ignore users with no matching skills

        match_fraction = matched_skills / total_requested
        match_percentage = match_fraction * 100

        skills_match_data[user_id] = {
            "match_percentage": match_percentage,
            "match_fraction": match_fraction,
            "matched_skills": matched_skills
        }

        if matched_skills == total_requested:
            found_n_n_match = True  

    if found_n_n_match:
        skills_match_data = {user_id: data for user_id, data in skills_match_data.items() if data["matched_skills"] == total_requested}

    return skills_match_data

def get_best_candidate(skills_match_data):
    if not skills_match_data:
        return None

    sorted_candidates = sorted(
        skills_match_data.items(),
        key=lambda x: (-x[1]["match_fraction"], -x[1]["match_percentage"])
    )

    return [user_id for user_id, _ in sorted_candidates] if sorted_candidates else None  

def process_requests():
    users_data = firebase_users()
    requests_data = firebase_requests()

    for request_id, request in requests_data.items():
        matches = compare(request, users_data)
        best_candidates = get_best_candidate(matches)

        returned_users = best_candidates if best_candidates else []

        db.collection("requests").document(request_id).update({
            "returnedUsers": returned_users,
            "status": "processed" if best_candidates else "no match found"
        })

# Firestore real-time listener
def on_snapshot(col_snapshot, changes, read_time):
    for change in changes:
        if change.type.name in ["ADDED", "MODIFIED"]:  # Trigger on new and updated requests
            print(f"Detected Firestore change, processing requests...")
            process_requests()

# Start listening for changes
request_ref = db.collection("requests")
request_ref.on_snapshot(on_snapshot)

# Keep script running
import time
while True:
    time.sleep(1)
