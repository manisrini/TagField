# TagField

A library to present a list of tagFields in a left aligned collectionView.

**SPM URL**: 
https://github.com/manisrini/TagField

**How to Use the TagField?**

*Initial Configuration*
` 
let tagComponent = TagFieldComponent()
let tags = [Tag(id: 1, text: "Mango"),Tag(id: 2, text: "Apple")]
let tagVM = TagFieldComponentViewModel(tags: tags,disableTextField: false)
tagComponent.config(viewModel: tagVM)
self.view.addSubview(tagComponent)
 `

- Can give the initial tags if needed by passing it through a param named "tags".
- Can disable the text field(in case of only displaying the tags) if needed.
- Get callback for the every character entered.

*Append a new tag :*
` self._tagComponent.appendNewTag(tag: tag)`

**TODO LIST : **
1.Need to introduce a configuration :
  1.1 Whether need a callback for every character or 
  1.2 Get a special character and add a tag when that character is entered.

