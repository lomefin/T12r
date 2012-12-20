#!usr/bin/ruby

NEW_VALUE_STRING ||= "NEW_VALUE"
def add_hash(hash)
  output = {}
  hash.keys.each do |key|
    output[key] = NEW_VALUE_STRING if !hash[key].is_a? Hash
    output[key] = add_hash(hash[key]) if hash[key].is_a? Hash
  end
  output
end


def check(struct_base, struct_target)
  return struct_target if !struct_base.is_a? Hash
  target = struct_target

  keys_to_add = struct_base.keys - struct_target.keys
  keys_to_check = struct_base.keys - keys_to_add

  keys_to_add.each do |key| 
    if struct_base[key].is_a? Hash
      target[key] = add_hash(struct_base[key]) 
    else
      target[key] = NEW_VALUE_STRING
    end
  end
  keys_to_check.each {|key| target[key] = check(struct_base[key],target[key])}
  target
end  

def sync(object1,object2)
  new_object2 = check(object1,object2)
  new_object1 = check(new_object2,object1)

  [new_object1,new_object2]
end

def test_sync

  a = { object_1: {
        property_1: 'value_1',
        property_2: 'value_2',
        property_5: 'value_5'
      },
      object_2: {
        element_1: 'el1',
        element_2: 'el2'
      },
      value_1: 'value_1'
    }

  b = {
        object_1: {
          property_1: 'value_1b',
          property_2: 'value_2b',
          property_3: 'value_3'
        },
        value_2: 'value_2'
  }
  a_expected = { 
        object_1: {
          property_1: 'value_1',
          property_2: 'value_2',
          property_5: 'value_5',
          property_3: 'NEW_VALUE'
        },
        object_2: {
          element_1: 'el1',
          element_2: 'el2'
        },
        value_1: 'value_1',
        value_2: 'NEW_VALUE'     
      }
  b_expected = {
        object_1: {
          property_1: 'value_1b',
          property_2: 'value_2b',
          property_3: 'value_3',
          property_5: 'NEW_VALUE',
        },
        object_2: {
          element_1: 'NEW_VALUE',
          element_2: 'NEW_VALUE'
        },
        value_1: 'NEW_VALUE',
        value_2: 'value_2',
  }

  c = { object_1:
        {
          obj_1: {
            el_1: '1.1',
            el_2: '1.2'
          }
        },
        object3: 
        {
          obj_1: 
          {
            el1: '3.1',
            el2: '3.2'
          }
        }
      }
  d = { object_1:
        {
          obj_1: {
            el_1: '1.1',
            el_3: '1.3'
          },
          obj_2: { alone: 'alone'}
        },
        object_2: 
        {
          el_1: 'el_1',
          obj_1: { value: '2.1.v'}
        },
        lonely_value: 'alone'
      }
  puts "Checking a"
  sync_result = sync(a,b)
  if sync_result[0] == a_expected
    puts "A OK"
  else
    puts "A Error"
    puts a.inspect
    puts a_expected.inspect
  end
  puts "Checking B"
  if sync_result[1] == b_expected
    puts "B OK"
  else
    puts "B Error"
    puts b.inspect
    puts b_expected.inspect
  end

  puts sync(c,d)[0].inspect
  puts sync(c,d)[1].inspect

end