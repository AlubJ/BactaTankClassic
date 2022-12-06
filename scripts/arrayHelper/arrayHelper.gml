#region Array Get Index

function array_get_index(array, value)
{
	for (var i = 0; i < array_length(array); i++)
	{
		if (array[i] == value) return i;
	}
	return -1;
}

#endregion

#region Array Add (add values of array)

function array_add(array, value)
{
	if (is_array(value) && array_length(value) == array_length(value))
	{
		var newArray = [];
		for (var i = 0; i < array_length(value); i++)
		{
			newArray[i] = array[i] + value[i];
		}
		return newArray;
	}
	return -1;
}

#endregion

#region Multiply Add (multiply values of array)

function array_multiply(array, value)
{
	var newArray = [];
	for (var i = 0; i < array_length(array); i++)
	{
		newArray[i] = array[i] + value;
	}
	return newArray;
}

#endregion