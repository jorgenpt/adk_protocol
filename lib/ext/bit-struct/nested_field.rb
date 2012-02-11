class BitStruct::NestedField
  def c_variable
    "#{nested_class.c_name} #{name}"
  end
end
