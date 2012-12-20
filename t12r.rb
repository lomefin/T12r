#!usr/bin/ruby
# Synchronizes two Hashes anatomy, every new value added to any of the hashes is marked with NEW_VALUE_STRING
# (c) Leonardo Luarte, 2012.


class T12r

  class ObjectIsNotAHashException < Exception
  end

  NEW_VALUE_STRING ||= "NEW_VALUE"
  def self.add_hash(hash)
    return NEW_VALUE_STRING unless hash.is_a? Hash
    output = {}
    hash.keys.each do |key|
      output[key] = NEW_VALUE_STRING if !hash[key].is_a? Hash
      output[key] = add_hash(hash[key]) if hash[key].is_a? Hash
    end
    output
  end


  def self.check(struct_base, struct_target)
    return struct_target if !struct_base.is_a? Hash
    target = struct_target

    keys_to_add = struct_base.keys - struct_target.keys
    keys_to_check = struct_base.keys - keys_to_add

    keys_to_add.each do |key| 
      target[key] = add_hash(struct_base[key]) 
    end
    keys_to_check.each {|key| target[key] = check(struct_base[key],target[key])}
    target
  end  
  def self.sync(object1,object2)
    if !object1.is_a? Hash then raise ObjectIsNotAHashException end
    if !object2.is_a? Hash then raise ObjectIsNotAHashException end
    new_object2 = check(object1,object2)
    new_object1 = check(new_object2,object1)

    [new_object1,new_object2]
  end

end
class T12rTester
  def self.test_sync

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
    sync_result = T12r.sync(a,b)
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

    #puts sync(c,d)[0].inspect
    #puts sync(c,d)[1].inspect

  end

  def self.test_add_hash

    puts "Checking a simple hash"
    a_hash = {a: 'a', b: 'b'}
    a_expected = {a: 'NEW_VALUE', b: 'NEW_VALUE'}

    if a_expected == (result = T12r.add_hash(a_hash))
      puts :OK
    else
      puts :ERROR
      puts result
    end

    puts "Checking a 2 tier hash"
    a_hash = {a: {a: 'a.a', b:'a.b'}, b: 'b'}
    a_expected = {a: {a: 'NEW_VALUE', b:'NEW_VALUE'}, b:'NEW_VALUE'}
    if a_expected == (result = T12r.add_hash(a_hash))
      puts :OK
    else
      puts :ERROR
      puts result
    end

    puts "Checking a 3 tier hash"
    a_hash = {a: {a: 'a.a', b: { a: 'a.b.a', b: 'a.b.b'},c:'a.c'}, b: {a: 'b.a'}}
    a_expected = {a: {a: 'NEW_VALUE', b:{a:'NEW_VALUE',b:'NEW_VALUE'},c:'NEW_VALUE'}, b:{a:'NEW_VALUE'}}
    if a_expected == (result = T12r.add_hash(a_hash))
      puts :OK
    else
      puts :ERROR
      puts result
    end

    puts "Checking a string"
    a_hash = 'A STRING'
    a_expected = 'NEW_VALUE'
    if a_expected == (result = T12r.add_hash(a_hash))
      puts :OK
    else
      puts :ERROR
      puts result
    end


  end

  def self.run_tests

    test_add_hash
    test_sync
  end
end