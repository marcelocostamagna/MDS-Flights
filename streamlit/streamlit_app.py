import os
import streamlit as st
import duckdb


def execute_query(query):
    con = duckdb.connect('db/flights.db') # Connect to your DuckDB database
    data = con.execute(query).fetchdf()
    con.close()
    return data


def get_origins():
    query = """
    SELECT DISTINCT origin 
    FROM delays 
    ORDER BY 1
    """
    return execute_query(query)


def get_delays_by_origin():
    query = """
    SELECT * 
    FROM total_delays_by_origin 
    ORDER BY origin
    """
    return execute_query(query)


def get_avg_delay_by_weekday(origin):
    query = f"""
    SELECT * 
    FROM avg_delays_by_weekday 
    WHERE origin = '{origin}' 
    ORDER BY dayofweek DESC
    """
    return execute_query(query)


def get_total_flights():
    query = f"""
    SELECT COUNT(*) AS total 
    FROM flights 
    """
    return execute_query(query)["total"]


def main():

    st.title('DuckDB Data Viewer')
    st.metric(label ="Total Flights", value=get_total_flights())

    st.subheader("Total Delay by Origin")
    st.bar_chart(data=get_delays_by_origin(), x='origin', y='total_delay')    

    selected_origin = st.sidebar.selectbox('Select Origins', get_origins())
    
    st.subheader("Average Delay by  Day of Week")
    st.write(f'Origin Selected: {selected_origin}')
    st.line_chart(data=get_avg_delay_by_weekday(selected_origin), x='dayname', y='avg_delay')


if __name__ == "__main__":
    
    db_path = 'db/flights.db'

    # Check if the database file exists
    if os.path.exists(db_path):
        # Connect to the database
        main()
        # conn = duckdb.connect(database=db_path)
        # st.write("Connected to the DuckDB database.")
    else:
        st.title("DuckDB database file does not exist.")