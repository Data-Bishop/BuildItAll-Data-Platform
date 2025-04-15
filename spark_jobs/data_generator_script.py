# Import libraries
import random

import pandas as pd
from faker import Faker

# Initialize faker and increase the seed for reproducibility
fake = Faker()
Faker.seed(42)


def generate_customers(n=500_000):
    """To generate 500,000 customers"""
    data = [{
        "customer_id": i,
        "name": fake.name(),
        "email": fake.email(),
        "signup_date": fake.date_between(start_date='-3y', end_date='today')
    } for i in range(1, n+1)]
    df = pd.DataFrame(data)
    return df


def generate_products(n=800_000):
    """To generate 800,000 products 'listed' on the website in different categories"""

    categories = ['Electronics', 'Jewelry', 'Shoes', 'Clothing', 'Tools', 'Books', 'Toys']
    data = [{
        "product_id": i,
        "name": fake.word().capitalize() + " " + fake.word().capitalize(),
        "category": random.choice(categories),
        "price": round(random.uniform(5.0, 500.0), 2)
    } for i in range(1, n+1)]
    df = pd.DataFrame(data)
    return df

def generate_orders(n=1_300_000, customer_count=500_000):
    """To generate 1.3M order transactions for our 500,000 customers"""

    data = [{
        "order_id": i,
        "customer_id": random.randint(1, customer_count),
        "order_date": fake.date_between(start_date='-2y', end_date='today'),
        "total": round(random.uniform(20.0, 1000.0), 2)
    } for i in range(1, n+1)]
    df = pd.DataFrame(data)
    return df

def generate_order_items(n=1_000_000, order_count=1_300_000, product_count=800_000):
    """To generate 1M order_items which would give details on order transactions on our listed products"""

    data = [{
        "order_id": random.randint(1, order_count),
        "product_id": random.randint(1, product_count),
        "quantity": random.randint(1, 5),
        "price": round(random.uniform(5.0, 300.0), 2)
    } for _ in range(n)]
    df = pd.DataFrame(data)
    return df

def generate_payments(n=1_500_000, order_count=1_300_000):
    """To generate 1.5M payment transactions details for our 1.3M order transactions"""
    
    methods = ['card', 'bank', 'transfer', 'cash_on_delivery','opay']
    statuses = ['completed', 'pending', 'failed']
    data = [{
        "payment_id": i,
        "order_id": random.randint(1, order_count),
        "method": random.choice(methods),
        "status": random.choice(statuses),
        "timestamp": fake.date_time_between(start_date='-2y', end_date='now')
    } for i in range(1, n+1)]
    df = pd.DataFrame(data)
    return df

if __name__ == "__main__":
    customers = generate_customers()
    products = generate_products()
    orders = generate_orders()
    order_items = generate_order_items()
    payments = generate_payments()