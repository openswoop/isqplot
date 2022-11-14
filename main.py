import streamlit as st
import pandas as pd
import plotly.express as px

df = pd.read_csv("./data/COP2220.csv")
simpleDF = df[["instructor", "average_gpa", "rating"]]

fig = px.scatter(simpleDF, x='rating', y='average_gpa',
              color='instructor')

st.header("COP2220 Rating vs GPA")
st.plotly_chart(fig, use_container_width=True)

meanDF = simpleDF
groupedByInstructorGPA = simpleDF.groupby(simpleDF["instructor"])['average_gpa'].mean()
groupedByInstructorRating = simpleDF.groupby(simpleDF["instructor"])['rating'].mean()

col, col2 = st.columns(2)
df_merged = pd.merge(groupedByInstructorGPA, groupedByInstructorRating, how="inner", on="instructor")
col.dataframe(df_merged)
col2.header("Highest Rank: " + df_merged.idxmax())
