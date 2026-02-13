# 1. Assign to a variable first
tempString="as,df,bd"

# 2. Perform the replacement on the variable
coll=(${tempString//,/ })

# Now you can check it:
echo ${coll[@]} # Outputs: as
