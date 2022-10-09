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