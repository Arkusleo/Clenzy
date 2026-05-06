import razorpay

RAZORPAY_KEY_ID = "rzp_test_SOLxtzwnLqUA87"
RAZORPAY_KEY_SECRET = "qRO6OncNl0v9nZUiywaQ3Oct"

try:
    client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))
    data = {
        "amount": 100,
        "currency": "INR",
        "receipt": "test_receipt"
    }
    order = client.order.create(data=data)
    print("Success:", order)
except Exception as e:
    print("Error:", e)
