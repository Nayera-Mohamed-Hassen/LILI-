
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["lili"]  # your MongoDB database name, adjust if needed
collection = db["recipes"]  # collection to store recipes

def insert_recipe(recipe_data: dict) -> bool:
    try:
        collection.insert_one(recipe_data)
        return True
    except Exception as e:
        print("MongoDB insert error:", e)
        return False


def insert_recipes(recipes):
    """Insert multiple recipes into the recipes collection."""
    result = collection.insert_many(recipes)
    print(f"Inserted recipe IDs: {result.inserted_ids}")

def main():
    db = client.recipe_db  # Database name
    recipes = [
        {
            "Title": "Miso-Butter Roast Chicken With Acorn Squash Panzanella",
            "Ingredients": [
                "1 (3½–4-lb.) whole chicken",
                "2¾ tsp. kosher salt, divided, plus more",
                "2 small acorn squash (about 3 lb. total)",
                "2 Tbsp. finely chopped sage",
                "1 Tbsp. finely chopped rosemary",
                "6 Tbsp. unsalted butter, melted, plus 3 Tbsp. room temperature",
                "¼ tsp. ground allspice",
                "Pinch of crushed red pepper flakes",
                "Freshly ground black pepper",
                "⅓ loaf good-quality sturdy white bread, torn into 1\" pieces (about 2½ cups)",
                "2 medium apples (such as Gala or Pink Lady; about 14 oz. total), cored, cut into 1\" pieces",
                "2 Tbsp. extra-virgin olive oil",
                "½ small red onion, thinly sliced",
                "3 Tbsp. apple cider vinegar",
                "1 Tbsp. white miso",
                "¼ cup all-purpose flour",
                "2 Tbsp. unsalted butter, room temperature",
                "¼ cup dry white wine",
                "2 cups unsalted chicken broth",
                "2 tsp. white miso",
                "Kosher salt, freshly ground pepper"
            ],
            "Instructions": ("Pat chicken dry with paper towels, season all over with 2 tsp. salt, and tie legs together with kitchen twine. "
                             "Let sit at room temperature 1 hour. Meanwhile, halve squash and scoop out seeds. Run a vegetable peeler along ridges of squash halves to remove skin. "
                             "Cut each half into ½\"-thick wedges; arrange on a rimmed baking sheet. Combine sage, rosemary, and 6 Tbsp. melted butter in a large bowl; pour half of mixture over squash on baking sheet. "
                             "Sprinkle squash with allspice, red pepper flakes, and ½ tsp. salt and season with black pepper; toss to coat. Add bread, apples, oil, and ¼ tsp. salt to remaining herb butter in bowl; "
                             "season with black pepper and toss to combine. Set aside. Place onion and vinegar in a small bowl; season with salt and toss to coat. Let sit, tossing occasionally, until ready to serve. "
                             "Place a rack in middle and lower third of oven; preheat to 425°F. Mix miso and 3 Tbsp. room-temperature butter in a small bowl until smooth. Pat chicken dry with paper towels, "
                             "then rub or brush all over with miso butter. Place chicken in a large cast-iron skillet and roast on middle rack until an instant-read thermometer inserted into the thickest part of breast registers 155°F, 50–60 minutes. "
                             "(Temperature will climb to 165°F while chicken rests.) Let chicken rest in skillet at least 5 minutes, then transfer to a plate; reserve skillet. Meanwhile, roast squash on lower rack until mostly tender, about 25 minutes. "
                             "Remove from oven and scatter reserved bread mixture over, spreading into as even a layer as you can manage. Return to oven and roast until bread is golden brown and crisp and apples are tender, about 15 minutes. "
                             "Remove from oven, drain pickled onions, and toss to combine. Transfer to a serving dish. Using your fingers, mash flour and butter in a small bowl to combine. Set reserved skillet with chicken drippings over medium heat. "
                             "You should have about ¼ cup, but a little over or under is all good. (If you have significantly more, drain off and set excess aside.) Add wine and cook, stirring often and scraping up any browned bits with a wooden spoon, until bits are loosened and wine is reduced by about half (you should be able to smell the wine), about 2 minutes. "
                             "Add butter mixture; cook, stirring often, until a smooth paste forms, about 2 minutes. Add broth and any reserved drippings and cook, stirring constantly, until combined and thickened, 6–8 minutes. Remove from heat and stir in miso. Taste and season with salt and black pepper. "
                             "Serve chicken with gravy and squash panzanella alongside."),
            "Image_Name": "miso-butter-roast-chicken-acorn-squash-panzanella",
            "Cleaned_Ingredients": [
                "1 (34-lb.) whole chicken",
                "2 tsp. kosher salt, divided, plus more",
                "2 small acorn squash (about 3 lb. total)",
                "2 Tbsp. finely chopped sage",
                "1 Tbsp. finely chopped rosemary",
                "6 Tbsp. unsalted butter, melted, plus 3 Tbsp. room temperature",
                " tsp. ground allspice",
                "Pinch of crushed red pepper flakes",
                "Freshly ground black pepper",
                " loaf good-quality sturdy white bread, torn into 1\" pieces (about 2 cups)",
                "2 medium apples (such as Gala or Pink Lady; about 14 oz. total), cored, cut into 1\" pieces",
                "2 Tbsp. extra-virgin olive oil",
                " small red onion, thinly sliced",
                "3 Tbsp. apple cider vinegar",
                "1 Tbsp. white miso",
                " cup all-purpose flour",
                "2 Tbsp. unsalted butter, room temperature",
                " cup dry white wine",
                "2 cups unsalted chicken broth",
                "2 tsp. white miso",
                "Kosher salt, freshly ground pepper"
            ],
            "Difficulty": "Advanced/Gourmet",
            "timeTaken": "Over 60 mins",
            "Diet": "Unclassified",
            "Cuisine": "French",
            "Meal Type": "Dinner"
        },
        {
            "Title": "Crispy Salt and Pepper Potatoes",
            "Ingredients": [
                "2 large egg whites",
                "1 pound new potatoes (about 1 inch in diameter)",
                "2 teaspoons kosher salt",
                "¾ teaspoon finely ground black pepper",
                "1 teaspoon finely chopped rosemary",
                "1 teaspoon finely chopped thyme",
                "1 teaspoon finely chopped parsley"
            ],
            "Instructions": ("Preheat oven to 400°F and line a rimmed baking sheet with parchment. In a large bowl, whisk the egg whites until foamy (there shouldn’t be any liquid whites in the bowl). "
                             "Add the potatoes and toss until they’re well coated with the egg whites, then transfer to a strainer or colander and let the excess whites drain. Season the potatoes with the salt, pepper, and herbs. "
                             "Scatter the potatoes on the baking sheet (make sure they’re not touching) and roast until the potatoes are very crispy and tender when poked with a knife, 15 to 20 minutes (depending on the size of the potatoes). "
                             "Transfer to a bowl and serve."),
            "Image_Name": "crispy-salt-and-pepper-potatoes-dan-kluger",
            "Cleaned_Ingredients": [
                "2 large egg whites",
                "1 pound new potatoes (about 1 inch in diameter)",
                "2 teaspoons kosher salt",
                " teaspoon finely ground black pepper",
                "1 teaspoon finely chopped rosemary",
                "1 teaspoon finely chopped thyme",
                "1 teaspoon finely chopped parsley"
            ],
            "Difficulty": "Quick & Easy (under 30 mins)",
            "timeTaken": "Under 30 mins",
            "Diet": "Vegetarian, Keto, Gluten-Free, Paleo, Low-Carb, Dairy-Free, Low-Fat, Whole30, Halal",
            "Cuisine": "French",
            "Meal Type": "Breakfast"
        }
    ]

    # Insert the recipes
    insert_recipes(recipes)

if __name__ == "__main__":
    main()