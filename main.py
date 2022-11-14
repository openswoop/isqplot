import streamlit as st
import pandas as pd
import plotly.express as px

df = pd.read_csv("./data/COP2220.csv")
simpleDF = df[["instructor", "average_gpa", "rating"]]

fig = px.scatter(simpleDF, x='rating', y='average_gpa',
              color='instructor')

st.header("COP2220 Rating vs GPA")
st.plotly_chart(fig, use_container_width=True)

meanDF = df.dropna()
meanDF["average_gpa"] = simpleDF.groupby(simpleDF["instructor"])['average_gpa'].mean()
meanDF["rating"] = simpleDF.groupby(simpleDF["instructor"])['rating'].mean()
st.table(meanDF)