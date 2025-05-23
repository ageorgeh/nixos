-- ~/.config/nvim/snippets/svelte.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("comp", {
		t({
			'<script lang="ts">',
			"  import type { WithElementRef } from 'bits-ui';",
			"  import { cn } from 'svelte-ag';",
			"  import type { HTMLDivAttributes } from 'svelte-ag';",
			"",
			"  let { class: className, ref = $bindable(null), children, ...restProps }: WithElementRef<HTMLDivAttributes> = $props();",
			"</script>",
			"",
			"<div bind:this={ref} class={cn(className)} {...restProps}>",
			"  {@render children?.()}",
			"</div>",
		}),
		i(0),
	}),
}
