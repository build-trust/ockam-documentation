# Access Controls and Policies

Attribute names can be used to define policies and policies can be used to define access controls:

* Policies are expressions involving attribute names, which can be evaluated to `true` or `false` given an environment containing attribute values.
* Access controls were discussed earlier. They restrict the messages which can be received or sent by a worker.

## Policies

Policies are boolean expressions constructed using attribute names. For example:

```scheme
(and (= resource.version 1)
     (= subject.name "John")
     (member? "John" resource.admins))
```

In the expression above:

* `and`, `=`, `member?` are operators.
* `resource.version`, `subject.name`, `resource.admins` are identifiers.
* `1`, `"John"` are values.

Values can have the 5 following types:

* `String`
* `Int`
* `Float`
* `Bool`
* `Seq`: a sequence of values

This table lists all the available operators:

| Operator  | Number of operands | Description                                                                                                  |
| --------- | ------------------ | ------------------------------------------------------------------------------------------------------------ |
| `and`     | >= 2               | Produce the logical conjunction of n expressions                                                             |
| `or`      | >= 2               | Produce the logical disjunction of n expressions                                                             |
| `not`     | 1                  | Produce the negation of an expression                                                                        |
| `if`      | 3                  | Evaluate the first expression to select either the second expression or the third one                        |
| `<`       | 2                  | Return true if the first value is less than the second one                                                   |
| `>`       | 2                  | Return true if the second value is less than the first one                                                   |
| `=`       | 2                  | Return true if the two values are equal                                                                      |
| `!=`      | 2                  | Return true if the two values are different                                                                  |
| `member?` | 2                  | Return true if the first value is present in the second expression, which must be a sequence `Seq` of values |
| `exists?` | >= 1               | Return true if all the expressions are identifiers with values present in the environment                    |

We evaluate a policy by doing the following:

* Each attribute `attribute_name/attribute_value` is added to the environment as an identifier `subject.attribute_name` associated to the value `attribute_value` (always as a `String`). In the example of a policy given above the identifier `subject.name` means that we are expecting an attribute `name` associated to the identity which sent a message.
* The top-level expression of the policy is recursively evaluated by evaluating each operator and taking values from the environment when an expression is referencing an identifier.
* The end result of a policy evaluation is simply a boolean saying if the policy succeeded or not.

## Access controls

The library offers two types of access controls using policies:

1. `AbacAccessControl`.
2. `PolicyAccessControl`.

### `AbacAccessControl`

This access control type is used as an `IncomingAccessControl` (so it restricts incoming messages).

We define an `AbacAccessControl` with the following:

1. A `Policy` which specifies which attributes are required for a given identity.
2. An `IdentityRepository` which stores a list of the known authenticated attributes for a given identity.

When a `LocalMessage` arrives to a worker using such an incoming access control, we do the following:

* If an identity is not associated to this message (as `LocalInfo`), the message is rejected.
* Otherwise the attributes for this identity are retrieved from the repository.
* The attributes are used to populate the policy environment.
* The policy expression is evaluated. If it returns `true` the message is accepted.

### `PolicyAccessControl`

This access control type is used as an `IncomingAccessControl` (so it restricts incoming messages).

We define a `PolicyAccessControl` with the following:

* A `PolicyRepository` which stores a list of policies.
* A `Resource` and an `Action`. They represent the access which we want to restrict.
* An `IdentityRepository` which stores a list of the known authenticated attributes for a given identity.

When a `LocalMessage` arrives to a worker using this type of incoming access control, we do the following:

* If an identity is not associated to this message (as `LocalInfo`), the message is rejected.
* Otherwise the attributes for this identity are retrieved from the repository.
* The most recent policy for the resource and the action is retrieved from the policy repository.
* The attributes are used to populate the policy environment.
* The policy expression is evaluated. If it returns `true` the message is accepted.

The two major differences between this policy and the previous one are:

1. The `PolicyAccessControl` models a `Resource/Action` pair.
2. Policies for that resource and action can be modified _even if the worker they are attached to is already started_.
