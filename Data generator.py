import random
import csv
import os
import pandas as pd
from faker import Faker
import itertools

fake = Faker()
Faker.seed(42)

# Define Constants
SMALL_ROOM_CAPACITY = 480
BIG_ROOM_CAPACITY = 2400
RETAKE_THRESHOLD = 30
MAX_STUDENTS_PER_CLASS = 1200

# Define Matura Subjects
basic_subjects = ["Mathematics", "Polish", "English"]
extended_subjects = ["Physics", "History", "Biology", "Chemistry", "Geography", "Mathematics", "Polish", "English"]
exam_levels = ["basic", "extended"]
subjects = list(set(extended_subjects + basic_subjects))

# Generate Matura Exam Data
def generate_matura_exam(year, start_id=1):
    matura_data = []
    matura_id = start_id
    
    for sub in basic_subjects:
        matura_data.append([matura_id, sub, "basic", year])
        matura_id += 1
    for sub in extended_subjects:
        matura_data.append([matura_id, sub, "extended", year])
        matura_id += 1
    
    return pd.DataFrame(matura_data, columns=["matura_id", "subject", "level", "year"])


# Generate Profile-Class Data
def generate_profile_class():
    classes = ["medical", "science", "economics", "law", "programming", "biological", "chemical", "linguistic"]
    class_extensions = {
        "medical": ["Biology", "Chemistry"],
        "science": ["Mathematics", "Physics"],
        "economics": ["Mathematics", "Geography"],
        "law": ["Polish", "History"],
        "programming": ["Mathematics", "Informatics"],
        "biological": ["Mathematics", "Biology"],
        "chemical": ["Mathematics", "Chemistry"],
        "linguistic": ["Polish", "English"]
    }
    profile_class = pd.DataFrame({
        "class_id": list(range(1, len(classes) + 1)),
        "class_name": classes,
        "description": [f"Extended subjects: {', '.join(class_extensions[c])}" for c in classes]
    })
    return profile_class

def generate_students(current_year, profile_class):
    students = []
    isRetaken = 0
    anulled = "NotAnulled"
    for class_id in profile_class["class_id"]:
        for _ in range(MAX_STUDENTS_PER_CLASS):
            students.append([
                fake.unique.random_number(digits=11), 
                f"{fake.first_name()} {fake.last_name()}",
                class_id,
                current_year,
                isRetaken,
                anulled  
            ])    
    return pd.DataFrame(students, columns=['student_PESEL', "student_name_surname", "class_id", "graduation_year", "isRetaken", "anulled"])


# Generate Teachers
def generate_teachers(year, num_teachers=28, prev_teachers=None):
    teachers = []
    if prev_teachers is not None:
        # If we have previous teachers, keep them
        teachers.extend(prev_teachers)
    
    # Add fixed PE teacher: Jan Kowalski
    pe_teacher_pesel = 99010112345  
    teachers.append([pe_teacher_pesel, "Jan", "Kowalski", "Physical Education", year])

    # Add new teachers or keep existing ones
    for _ in range(num_teachers - len(teachers)):
        teachers.append([fake.unique.random_number(digits=11), fake.first_name(), fake.last_name(), random.choice(subjects), year])
    return pd.DataFrame(teachers, columns=['PESEL', 'Name', 'Surname', 'Subject', "Year"])


# Generate Rooms
def generate_rooms(num_rooms=20):
    rooms = []
    for room_id in range(1, num_rooms + 1):
        capacity = BIG_ROOM_CAPACITY if random.choice([True, False]) else SMALL_ROOM_CAPACITY
        rooms.append((f"Room_{room_id}", capacity))
    rooms = rooms + [("Room_21", BIG_ROOM_CAPACITY)]
    return rooms

# Generate Exam Groups 
def generate_exam_groups(students_df, matura_exam, teachers, classrooms):
    group_size_options = [15, 40]
    student_groups = []
    
    for student in students_df.itertuples():
        student_subjects = matura_exam[(matura_exam["level"] == "basic")]
        num_extended = random.randint(1, 6)
        extended_subjects_sample = matura_exam[(matura_exam["level"] == "extended")].sample(num_extended)
        student_exams = pd.concat([student_subjects, extended_subjects_sample])

        for _, exam in student_exams.iterrows():
            group_size = random.choice(group_size_options)
            if group_size == 15:
                classroom = random.choice([room for room in classrooms if room[1] == SMALL_ROOM_CAPACITY])
            else:
                classroom = random.choice([room for room in classrooms if room[1] == BIG_ROOM_CAPACITY])

            # assign a teacher who does NOT teach the same subject as the exam
            available_teachers = teachers[teachers["Subject"] != exam["subject"]]
            teacher = available_teachers.sample(1).iloc[0]

            student_groups.append({
                "student_PESEL": student.student_PESEL,
                "matura_id": exam["matura_id"],  
                "subject": exam["subject"],
                "level": exam["level"],
                "year": exam["year"],
                "classroom": classroom[0], 
                "classroom_capacity": "small" if classroom[1] == SMALL_ROOM_CAPACITY else "big",
                "teacher_PESEL": teacher["PESEL"],
                "subject_teacher": teacher["Subject"],
                "isRetaken": student.isRetaken,
                "anulled": student.anulled
            })
    
    return pd.DataFrame(student_groups)

# Generate Matura Results
def result_generator():
    return round(random.uniform(0, 1), 2)

def generate_matura_results(student_groups_df):
    results = []
    
    for group in student_groups_df.itertuples():
        result = result_generator()

        if group.level == "basic":
            passed = "Passed" if result >= 0.3 else "NotPassed"
        elif group.level == "extended":
            passed = "Passed"  
            
        duration = random.randint(80, 120)

        results.append({
            "student_PESEL": group.student_PESEL,
            "matura_id": group.matura_id,
            "subject": group.subject,
            "level": group.level,
            "result": result,
            "passed": passed,
            "year": group.year,
            "teacher_PESEL": group.teacher_PESEL,
            "classroom": group.classroom,
            "classroom_capacity": group.classroom_capacity,
            "duration": duration,
            "isRetaken": group.isRetaken,
            "anulled": group.anulled
        })
    
    return pd.DataFrame(results)


# Generate Retakes
def generate_retakes(matura_results_df): 
    failed_students_df = matura_results_df[matura_results_df["passed"] == "NotPassed"]
    retake_students_df = failed_students_df[['student_PESEL', 'matura_id', 'year']].drop_duplicates()
    
    math_extended_failures = matura_results_df[
        (matura_results_df["subject"] == "Mathematics") & 
        (matura_results_df["level"] == "extended") & 
        (matura_results_df["result"] <= 80)
    ]

    num_retakers = random.randint(2, 4)
    extended_math_retakers = math_extended_failures.sample(min(num_retakers, len(math_extended_failures)))
    retake_students_df = pd.concat([retake_students_df, extended_math_retakers[['student_PESEL', 'matura_id', 'year']]], ignore_index=True)
    retake_students_df = retake_students_df.drop_duplicates()
    return retake_students_df

def change_random_teacher_subject(teachers_df):
    teacher_idx = random.choice(teachers_df.index.tolist())
    current_subject = ["Math", "Biology", "History", "Geography", "Physics", "Chemistry", "Polish", "English"]
    new_subject_choices = [sub for sub in subjects if sub != current_subject]
    new_subject = random.choice(new_subject_choices)

    teachers_df.at[teacher_idx, 'Subject'] = new_subject
    return teachers_df

def simulate_absent_students(matura_results_df, percent_absent=0.005):
    matura_results_df = matura_results_df.copy()
    
    unique_students = matura_results_df['student_PESEL'].unique()
    num_to_absent = max(1, int(len(unique_students) * percent_absent))
    absent_students = random.sample(list(unique_students), num_to_absent)

    
    for pesel in absent_students:
        student_exams = matura_results_df[matura_results_df['student_PESEL'] == pesel]
        if student_exams.empty:
            continue
        exam_to_null = student_exams.sample(1).index[0]
        matura_results_df.loc[exam_to_null, ['duration', 'result', 'passed']] = None
    return matura_results_df

def remove_duplicate_pesels(new_students_df, previous_students_df):
    previous_pesels = previous_students_df["student_PESEL"].tolist()
    new_students_unique = new_students_df[~new_students_df["student_PESEL"].isin(previous_pesels)]
    return new_students_unique

def remove_similar_pesels(new_students_df, teachers):
    teacher_pesels = teachers["PESEL"].tolist()
    filtered_students = new_students_df[~new_students_df["student_PESEL"].isin(teacher_pesels)]
    return filtered_students


def annul_random_exam(matura_results_df, retake_students_df):
    matura_results_df = matura_results_df.copy()
    retake_students_df = retake_students_df.copy()

    # Step 1: Pick a random (matura_id, classroom) group
    unique_groups = matura_results_df.groupby(["matura_id", "classroom"]).size().reset_index()[["matura_id", "classroom"]]
    if unique_groups.empty:
        print("No exam groups found.")
        return matura_results_df, retake_students_df

    selected_group = unique_groups.sample(1).iloc[0]
    selected_matura_id = selected_group["matura_id"]
    selected_classroom = selected_group["classroom"]

    # Step 2: Find the group in the results
    annulled_mask = (
        (matura_results_df["matura_id"] == selected_matura_id) &
        (matura_results_df["classroom"] == selected_classroom)
    )

    # Step 3: Set their results to None and isRetaken to 1
    matura_results_df.loc[annulled_mask, ["result", "duration", "passed"]] = None
    matura_results_df.loc[annulled_mask, "isRetaken"] = 1
    matura_results_df.loc[annulled_mask, "anulled"] = "Anulled"

    # Step 4: Add to retake list
    annulled_students = matura_results_df.loc[annulled_mask, ["student_PESEL", "matura_id", "year"]]
    retake_students_df = pd.concat([retake_students_df, annulled_students], ignore_index=True).drop_duplicates()

    print(f"Annulled exam: matura_id {selected_matura_id}, classroom {selected_classroom}")
    return matura_results_df, retake_students_df


def concatenate_bulk_files(file_prefix, years, output_suffix):
    dfs = []
    for year in years:
        filename = f"{file_prefix}_{year}.bulk"
        df = pd.read_csv(filename, sep='|')
        dfs.append(df)
    
    combined_df = pd.concat(dfs, ignore_index=True)
    combined_df.to_csv(f"{file_prefix}_{output_suffix}.bulk", index=False, sep='|')

def concatenate_csv_files(file_prefix, years, output_suffix):
    dfs = []
    for year in years:
        filename = f"{file_prefix}_{year}.csv"
        df = pd.read_csv(filename)
        dfs.append(df)

    combined_df = pd.concat(dfs, ignore_index=True)
    combined_df.to_csv(f"{file_prefix}{output_suffix}.csv", index=False)


    


def assign_retakes(matura_results_df, retake_students_df, matura_exam, teachers, classrooms):
    retake_entries = []
    year = retake_students_df['year'].iloc[0]

    # Get the PE teacher
    pe_teacher = teachers[teachers['Subject'] == 'Physical Education']
    if pe_teacher.empty:
        default_pe_teacher = pd.DataFrame([{
            'PESEL': '99010112345',
            'Name': 'Jan',
            'Surname': 'Kowalski',
            'Subject': 'Physical Education',
            'Year': year
        }])
        teachers = pd.concat([teachers, default_pe_teacher], ignore_index=True)
    pe_teacher_pesel = pe_teacher["PESEL"].iloc[0]

    # Get Room_21
    room_pe = next((room for room, capacity in classrooms if room == 'Room_21'), None)
    if room_pe is None:
        room_pe = classrooms[0][0]

    # Join to get exam info (subject, level)
    exam_info = matura_results_df[['matura_id', 'subject', 'level']].drop_duplicates()
    retake_info_df = pd.merge(retake_students_df, exam_info, on='matura_id', how='left')

    # Remove duplicates in case a student has multiple identical rows
    retake_info_df = retake_info_df.drop_duplicates(subset=['student_PESEL', 'matura_id', 'subject'])

    # Iterate over unique retake requests
    for row in retake_info_df.itertuples():
        duration = random.randint(80, 120)
        result = result_generator()
        passed = "Passed" if (row.level == "extended" or result >= 0.30) else "NotPassed"

        retake_entries.append({
            "student_PESEL": row.student_PESEL,
            "matura_id": row.matura_id,
            "subject": row.subject,
            "level": row.level,
            "result": result,
            "passed": passed,
            "year": year,
            "teacher_PESEL": pe_teacher_pesel,
            "subject_teacher": "Physical Education",
            "classroom": room_pe,
            "classroom_capacity": "big",
            "duration": duration,
            "isRetaken": 1,
            "anulled": "NotAnulled"
        })

    return pd.DataFrame(retake_entries)


# Main function to generate data for the given year
def generate_data(year, load_previous=False):
    if load_previous:
        profile_class = pd.read_csv(f"profile_class_{year-1}.bulk", sep='|')
        matura_exam = pd.read_csv(f"matura_{year-1}.bulk", sep='|')
        teachers = pd.read_csv(f"teachers_{year-1}.bulk", sep='|')
        classrooms_df = pd.read_csv(f"classrooms_{year-1}.bulk", sep='|')
        classrooms = list(classrooms_df.itertuples(index=False, name=None))
        previous_students = pd.read_csv(f"students_{year-1}.bulk", sep='|')

        previous_retakes = pd.read_csv(f"retake_students_{year-1}.bulk", sep='|')
        prev_matura_results_df = pd.read_csv(f"matura_results_{year-1}.bulk", sep='|')
        assigned_retakes=assign_retakes(prev_matura_results_df, previous_retakes, matura_exam, teachers, classrooms)
        assigned_retakes.to_csv(f"assigned_retakes_{year}.bulk", index=False, sep='|')
        
        start_id = matura_exam['matura_id'].max() + 1
        matura_exam_new = generate_matura_exam(year, start_id)
        matura_exam = pd.concat([matura_exam, matura_exam_new], ignore_index=True)
    else:
        matura_exam = generate_matura_exam(year)
        profile_class = generate_profile_class()
        teachers = generate_teachers(year)
        classrooms = generate_rooms()
    
    students = generate_students(year, profile_class) 

    if load_previous:
        students = remove_duplicate_pesels(students, previous_students)
        students = remove_similar_pesels(students,teachers)
        student_groups_df = generate_exam_groups(students, matura_exam_new, teachers, classrooms)
    else:
         student_groups_df = generate_exam_groups(students, matura_exam, teachers, classrooms)

    teachers = change_random_teacher_subject(teachers)  # USE THIS TO CHANGE TEACHING SUBJECT


    matura_results_df = generate_matura_results(student_groups_df)
    matura_results_df = simulate_absent_students(matura_results_df, percent_absent=0.005) #USE THIS TO SIMULATE ABSENT STUDENTS
    #matura_results_df = pd.concat([matura_results_df, assigned_retakes], ignore_index=True)

    #ANULLED LOGIC
    retake_students_df = generate_retakes(matura_results_df)

    matura_results_df, retake_students_df = annul_random_exam(matura_results_df, retake_students_df)


    classrooms_df = pd.DataFrame(classrooms, columns=['Room', 'Capacity']) 
    profile_class.to_csv(f"profile_class_{year}.bulk", index=False, sep='|')
    matura_exam.to_csv(f"matura_{year}.bulk", index=False, sep='|')
    students.to_csv(f"students_{year}.bulk", index=False, sep='|')
    teachers.to_csv(f"teachers_{year}.bulk", index=False, sep='|')
       
    classrooms_df.to_csv(f"classrooms_{year}.bulk", index=False, sep='|')
    #student_groups_df.to_csv(f"exam_schedule_{year}.csv", index=False)  
    #matura_results_df.to_csv(f"matura_results_{year}.bulk", index=False, sep='|')
    
    
    if load_previous:
        matura_results_df = pd.concat([matura_results_df, assigned_retakes], ignore_index=True)
    matura_results_bulk = matura_results_df.copy()
    matura_results_bulk.to_csv(f"matura_results_{year}.bulk", index=False, sep='|')
    retake_students_df.to_csv(f"retake_students_{year}.bulk", index=False, sep='|')

    #student_matura_result = matura_results_df[['student_PESEL', 'matura_id', 'result', 'passed', 'duration','isRetaken','anulled']] 
    #student_matura_result.to_csv(f"student_matura_result{year}.bulk", index=False, sep='|') 
    exam_schedule = matura_results_df[['student_PESEL', 'matura_id','subject','level','year', 'classroom', 'classroom_capacity','teacher_PESEL','isRetaken','anulled']].copy()
    exam_schedule = exam_schedule.merge(student_groups_df[['student_PESEL', 'matura_id', 'subject_teacher']], on=['student_PESEL', 'matura_id'],
    how='left'
    )
    exam_schedule.loc[exam_schedule['isRetaken'] == 1, 'subject_teacher'] = "Physical Education"
    exam_schedule = exam_schedule[['student_PESEL', 'matura_id','subject','level','year', 'classroom', 'classroom_capacity','teacher_PESEL','subject_teacher','isRetaken','anulled']]
    student_matura_result = matura_results_df[['student_PESEL', 'matura_id', 'result', 'passed', 'duration','isRetaken','anulled']].copy()
    student_matura_result.to_csv(f"student_matura_result_{year}.bulk", index=False, sep='|')
    exam_schedule.to_csv(f"exam_schedule_{year}.csv", index=False) 


if __name__ == "__main__":

 
    generate_data(2018, load_previous=False)
    generate_data(2019, load_previous=True)
    generate_data(2020, load_previous=True)
    generate_data(2021, load_previous=True) 
    generate_data(2022, load_previous=True)
    generate_data(2023, load_previous=True)
    generate_data(2024, load_previous=True)
    

