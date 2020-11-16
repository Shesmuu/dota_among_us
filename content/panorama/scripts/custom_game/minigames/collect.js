class MinigameCollect extends Minigame {
	constructor() {
		super( "#au_minigame_collect_title", "CollectContainer" )

		this.type = AU_MINIGAME_COLLECT
		this.container.BLoadLayoutSnippet( "MinigameCollect" )
		this.itemTable = CustomNetTables.GetTableValue( "game", "minigame_collect_items" )
		this.emptySlots = []
		this.needItems = []

		const allItems = this.container.FindChildTraverse( "AllItemsContainer" )
		const random = []
		const allVarItems = []
		let varItemCount = 10

		for ( let itemName in this.itemTable ) {
			random.push( itemName )

			const row = $.CreatePanel( "Panel", allItems, "" )
			row.AddClass( "Row" )

			const item = $.CreatePanel( "DOTAItemImage", row, "" )
			item.itemname = itemName

			const arrow = $.CreatePanel( "Panel", row, "" )
			arrow.AddClass( "Arrow" )

			for ( let i in this.itemTable[itemName] ) {
				const cItemName = this.itemTable[itemName][i]
				const cItem = $.CreatePanel( "DOTAItemImage", row, "" )
				cItem.itemname = cItemName

				if ( !allVarItems.includes( cItemName ) ) {
					allVarItems.push( cItemName )
				}
			}
		}

		this.collectingItem = random[RandomInt( 0, random.length - 1 )]
		this.container.FindChildTraverse( "CollectItem" ).itemname = this.collectingItem

		const emptyContainer = this.container.FindChildTraverse( "EmptySlots" )
		const varItemsContainer = this.container.FindChildTraverse( "VarItemSlots" )
		const varItems = []

		for ( let i in this.itemTable[this.collectingItem] ) {
			const item = this.itemTable[this.collectingItem][i]
			varItems.push( item )

			const empty = $.CreatePanel( "DOTAItemImage", emptyContainer, "" )

			this.emptySlots.push( empty )
			this.needItems.push( item )

			varItemCount--
		}

		for ( let i = 0; i < varItemCount; i++ ) {
			varItems.push( allVarItems[RandomInt( 0, allVarItems.length - 1 )] )
		}

		for ( let i in varItems ) {
			const r = RandomInt( 0, varItems.length - 1 )
			const a = varItems[i]
			const b = varItems[r]

			varItems[i] = b
			varItems[r] = a
		}

		for ( let i in varItems ) {
			const item = $.CreatePanel( "DOTAItemImage", varItemsContainer, "" )
			item.itemname = varItems[i]

			item.SetPanelEvent( "onactivate", () => {
				this.SelectItem( item, varItems[i] )
			} )
		}
	}

	SelectItem( panel, itemName ) {
		const empty = this.emptySlots[0]

		if ( !empty ) {
			return
		}

		let itemIndex = undefined

		for ( let i in this.needItems ) {
			const item = this.needItems[i]

			if ( item == itemName ) {
				itemIndex = i
			}
		}

		if ( itemIndex == undefined ) {
			this.FailDelay( 1.3, "#au_minigame_failure_1" )

			return
		}

		this.emptySlots.splice( 0, 1 )
		this.needItems.splice( itemIndex, 1 )

		empty.itemname = itemName

		if ( !this.needItems[0] ) {
			this.Complete( 2, "#au_minigame_good_1" )
		}

		panel.AddClass( "Selected" )
		panel.SetPanelEvent( "onactivate", () => {} )
	}
}