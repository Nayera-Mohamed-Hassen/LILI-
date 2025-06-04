import json
import os
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import IsolationForest
from sentence_transformers import SentenceTransformer
from datetime import datetime

# ---------- AI Setup ----------
training_data = {
    "description": [
        "tshirt", "dress", "jeans", "shoes", "jacket", "skirt",
        "apple", "bread", "milk", "grocery", "restaurant", "chocolate", "egg", "banana",
        "electricity bill", "water bill", "internet", "rent", "gas bill",
        "netflix", "movie", "game", "cinema", "spotify",
        "uber", "bus ticket", "train", "flight", "taxi",
        "gift", "accessories", "donation", "books", "subscription", "miscellaneous"
    ],
    "category": [
        "clothes", "clothes", "clothes", "clothes", "clothes", "clothes",
        "food", "food", "food", "food", "food", "food", "food", "food",
        "utilities", "utilities", "utilities", "utilities", "utilities",
        "entertainment", "entertainment", "entertainment", "entertainment", "entertainment",
        "transport", "transport", "transport", "transport", "transport",
        "others", "others", "others", "others", "others", "others"
    ]
}

embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
X_embed = embedding_model.encode(training_data["description"])
y_train = training_data["category"]

clf = KNeighborsClassifier(n_neighbors=3)
clf.fit(X_embed, y_train)

# ---------- Data Paths ----------
DATA_FILE = "expense_history.json"
INCOME_FILE = "monthly_income.json"

def load_json(file_path):
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            return json.load(f)
    return {}

def save_json(data, file_path):
    with open(file_path, "w") as f:
        json.dump(data, f, indent=2)

# ---------- Anomaly Detection ----------
def detect_spending_anomalies(history):
    monthly_data = []
    for month, records in history.items():
        df = pd.DataFrame(records)
        if not df.empty:
            month_totals = df.groupby("category")["amount"].sum().to_dict()
            for category, amount in month_totals.items():
                monthly_data.append({"month": month, "category": category, "amount": amount})
    df = pd.DataFrame(monthly_data)
    anomalies = []
    if not df.empty:
        for cat in df["category"].unique():
            subset = df[df["category"] == cat].sort_values("month")
            if len(subset) >= 4:
                model = IsolationForest(contamination=0.2, random_state=42)
                subset["anomaly"] = model.fit_predict(subset[["amount"]])
                anomalies += subset[subset["anomaly"] == -1][["month", "category", "amount"]].to_dict("records")
    return anomalies

# ---------- Main Budget System ----------
def run_budget_system():
    month = datetime.now().strftime("%Y-%m")
    income_record = load_json(INCOME_FILE)
    history = load_json(DATA_FILE)

    if month not in income_record:
        income = float(input("Enter your monthly income: "))
        income_record[month] = {"income": income, "spent": 0}
    else:
        income = income_record[month]["income"]

    remaining = income - income_record[month]["spent"]
    print(f"\n💰 Remaining budget for {month}: ${remaining:.2f}")

    num_expenses = int(input("How many expenses do you want to enter? "))
    new_expenses = []
    for _ in range(num_expenses):
        desc = input("Expense description: ").strip().lower()
        amount = float(input(f"Amount spent on '{desc}': "))
        category = clf.predict(embedding_model.encode([desc]))[0]
        new_expenses.append({"description": desc, "amount": amount, "category": category})
        income_record[month]["spent"] += amount

    if income_record[month]["spent"] > income:
        print(f"⚠️ Warning: You have exceeded your monthly income by ${income_record[month]['spent'] - income:.2f}!")

    # Save data
    if month not in history:
        history[month] = []
    history[month].extend(new_expenses)
    save_json(history, DATA_FILE)
    save_json(income_record, INCOME_FILE)

    # Summary
    df_month = pd.DataFrame(history[month])
    total_spent = df_month["amount"].sum()
    print("\n--- Budget Summary ---")
    print(f"Total Income: ${income:.2f}")
    print(f"Total Spent: ${total_spent:.2f}")
    print(f"Remaining Budget: ${income - total_spent:.2f}\n")

    print("📅 Spending by Category This Month:")
    print(df_month.groupby("category")["amount"].sum().sort_values(ascending=False).to_string())

    # Suggestions
    suggestions = {
        "food": "Try to reduce food expenses by cooking at home.",
        "clothes": "Limit buying more clothes, reuse or shop during sales.",
        "utilities": "Consider reducing electricity, water, or internet usage.",
        "entertainment": "Cut back on subscriptions or outings.",
        "transport": "Use public transport more or reduce fuel usage.",
        "others": "Review miscellaneous purchases for necessity."
    }
    top_cat = df_month.groupby("category")["amount"].sum().idxmax()
    print(f"\n🔔 Highest spending: {top_cat}")
    print("💡 " + suggestions.get(top_cat, "Review spending habits."))

    # Anomaly Detection
    anomalies = detect_spending_anomalies(history)
    if anomalies:
        print("\n⚠️ Detected Irregularities in Spending:")
        for a in anomalies:
            print(f"  - In {a['month']}, unusually high spending on {a['category']} (${a['amount']:.2f})")

# ---------- Run ----------
if __name__ == "__main__":
    run_budget_system()
