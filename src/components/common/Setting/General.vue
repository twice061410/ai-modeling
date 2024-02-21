<script lang="ts" setup>
import {computed, reactive} from 'vue'
import {NButton, NPopconfirm, NSelect, useMessage, NInputGroup} from 'naive-ui'
import type {Language, Theme} from '@/store/modules/app/helper'
import {SvgIcon} from '@/components/common'
import {useAppStore} from '@/store'
// import type { UserInfo } from '@/store/modules/user/helper'
import {getCurrentDate} from '@/utils/functions'
import {useBasicLayout} from '@/hooks/useBasicLayout'
import {t} from '@/locales'
import axios from "axios";

const appStore = useAppStore()

const {isMobile} = useBasicLayout()

const ms = useMessage()

const theme = computed(() => appStore.theme)

// const userInfo = computed(() => userStore.userInfo)

// const avatar = ref(userInfo.value.avatar ?? '')

// const name = ref(userInfo.value.name ?? '')

const state = reactive({
	jihuoloading: false,
	//激活码
	apikey: "",
	jihuotext: "激活",
	jihuoids: false,
})

//激活函数
const jihuo = () => {
	if (localStorage.getItem("username")) {
		state.jihuoids = true;
		if (state.apikey != "" && localStorage.getItem("username")) {
			state.jihuoloading = true;
			state.jihuotext = "激活中";
			axios.post("http://106.53.97.117:2088/ups", {
				sql: `select * from activation_codes where apikey = '${state.apikey}' and status='true'`
			}).then(res => {
				if (res.data.data[0]) {
					console.log(res.data.data[0]['level'])
					switch (res.data.data[0]['level']) {
						// Xstudio新手版【梦想60次】
						case 1:
							axios.post("http://106.53.97.117:2088/ups", {
								sql: `update  admin set scorea = scorea + 60 where name = '${localStorage.getItem("username")}'`
							}).then(res => {
								axios.post("http://106.53.97.117:2088/ups", {
									sql: `update activation_codes set status = 'false' where apikey='${state.apikey}'`
								}).then(res => {
									location.reload();
									state.jihuotext = "激活";
									ms.success("激活成功！正在跳转更新~")
									state.jihuoids = false;
									state.jihuoloading = false;
								})
							})
							break;
						//加500次 梦想版
						case 2:
							axios.post("http://106.53.97.117:2088/ups", {
								sql: `update  admin set scorea = scorea + 500 where name = '${localStorage.getItem("username")}'`
							}).then(res => {
								axios.post("http://106.53.97.117:2088/ups", {
									sql: `update activation_codes set status = 'false' where apikey='${state.apikey}'`
								}).then(res => {
									location.reload();
									state.jihuotext = "激活";
									ms.success("激活成功！正在跳转更新~")
									state.jihuoids = false;
									state.jihuoloading = false;
								})
							})
							break;
						//	Xstudio尊贵版【梦想1000次 ＋精灵100次】
						case 3:
							axios.post("http://106.53.97.117:2088/ups", {
								sql: `update  admin set scorea = scorea + 1000,scoreb = scoreb + 100 where name = '${localStorage.getItem("username")}'`
							}).then(res => {
								axios.post("http://106.53.97.117:2088/ups", {
									sql: `update activation_codes set status = 'false' where apikey='${state.apikey}'`
								}).then(res => {
									location.reload();
									state.jihuotext = "激活";
									ms.success("激活成功！正在跳转更新~")
									state.jihuoids = false;
									state.jihuoloading = false;
								})
							})
							break;
						//		Xstudio至尊版【梦想2000次 ＋精灵220次】
						case 4:
							axios.post("http://106.53.97.117:2088/ups", {
								sql: `update  admin set scorea = scorea + 2000,scoreb = scoreb + 220 where name = '${localStorage.getItem("username")}'`
							}).then(res => {
								axios.post("http://106.53.97.117:2088/ups", {
									sql: `update activation_codes set status = 'false' where apikey='${state.apikey}'`
								}).then(res => {
									location.reload();
									state.jihuotext = "激活";
									ms.success("激活成功！正在跳转更新~")
									state.jihuoids = false;
									state.jihuoloading = false;
								})
							})
							break;
					}

				} else {
					ms.error("密钥错误或者已经被使用！")
					state.jihuoloading = false;
					state.jihuotext = "激活";
					state.jihuoids = false;
					return
				}
			}).catch(error => {
				ms.error("密钥错误或者已经被使用！")
				console.error(error);
				state.jihuoloading = false;
				state.jihuotext = "激活";
				state.jihuoids = false;
			})
		} else {
			state.jihuoids = false;
			ms.error("请填写激活密钥")
		}

	} else {
		ms.warning("请先登录")
	}

}


const language = computed({
	get() {
		return appStore.language
	},
	set(value: Language) {
		appStore.setLanguage(value)
	},
})

const themeOptions: { label: string; key: Theme; icon: string }[] = [
	{
		label: 'Auto',
		key: 'auto',
		icon: 'ri:contrast-line',
	},
	{
		label: 'Light',
		key: 'light',
		icon: 'ri:sun-foggy-line',
	},
	{
		label: 'Dark',
		key: 'dark',
		icon: 'ri:moon-foggy-line',
	},
]

const languageOptions: { label: string; key: Language; value: Language }[] = [
	{label: '简体中文', key: 'zh-CN', value: 'zh-CN'},
	{label: '繁體中文', key: 'zh-TW', value: 'zh-TW'},
	{label: 'English', key: 'en-US', value: 'en-US'},
	{label: '한국어', key: 'ko-KR', value: 'ko-KR'},
	{label: 'Русский язык', key: 'ru-RU', value: 'ru-RU'},
]

// function updateUserInfo(options: Partial<UserInfo>) {
//   userStore.updateUserInfo(options)
//   ms.success(t('common.success'))
// }

// function handleReset() {
//   userStore.resetUserInfo()
//   ms.success(t('common.success'))
//   window.location.reload()
// }

function exportData(): void {
	const date = getCurrentDate()
	const data: string = localStorage.getItem('chatStorage') || '{}'
	const jsonString: string = JSON.stringify(JSON.parse(data), null, 2)
	const blob: Blob = new Blob([jsonString], {type: 'application/json'})
	const url: string = URL.createObjectURL(blob)
	const link: HTMLAnchorElement = document.createElement('a')
	link.href = url
	link.download = `chat-store_${date}.json`
	document.body.appendChild(link)
	link.click()
	document.body.removeChild(link)
}

function importData(event: Event): void {
	const target = event.target as HTMLInputElement
	if (!target || !target.files)
		return

	const file: File = target.files[0]
	if (!file)
		return

	const reader: FileReader = new FileReader()
	reader.onload = () => {
		try {
			console.log(reader.result)
			const data = JSON.parse(reader.result as string)
			console.log(data.data.chat[0].data[0].text)
			console.log(typeof (data.data.chat[0].data[0].text))
			localStorage.setItem('chatStorage', JSON.stringify(data))
			ms.success(t('common.success'))
			location.reload()
		} catch (error) {
			ms.error(t('common.invalidFileFormat'))
		}
	}
	reader.readAsText(file)
}

function clearData(): void {
	localStorage.removeItem('chatStorage')
	location.reload()
}

function handleImportButtonClick(): void {
	const fileInput = document.getElementById('fileInput') as HTMLElement
	if (fileInput)
		fileInput.click()
}
</script>

<template>
	<div class="p-4 space-y-5 min-h-[200px]">
		<div class="space-y-6">
<!--			      <div class="flex items-center space-x-4">-->
<!--			        <span class="flex-shrink-0 w-[100px]">{{ $t('setting.avatarLink') }}</span>-->
<!--			        <div class="flex-1">-->
<!--			          <NInput v-model:value="avatar" placeholder="" />-->
<!--			        </div>-->
<!--			        <NButton size="tiny" text type="primary" @click="updateUserInfo({ avatar })">-->
<!--			          {{ $t('common.save') }}-->
<!--			        </NButton>-->
<!--			      </div>-->
<!--			      <div class="flex items-center space-x-4">-->
<!--			        <span class="flex-shrink-0 w-[100px]">{{ $t('setting.name') }}</span>-->
<!--			        <div class="w-[200px]">-->
<!--			          <NInput v-model:value="name" placeholder="" />-->
<!--			        </div>-->
<!--			        <NButton size="tiny" text type="primary" @click="updateUserInfo({ name })">-->
<!--			          {{ $t('common.save') }}-->
<!--			        </NButton>-->
<!--			      </div>-->
			<div
				class="flex items-center space-x-4"
				:class="isMobile && 'items-start'"
			>
				<span class="flex-shrink-0 w-[100px]">互动记录</span>

				<div class="flex flex-wrap items-center gap-4">
					<NButton size="small" @click="exportData">
						<template #icon>
							<SvgIcon icon="ri:download-2-fill"/>
						</template>
						{{ $t('common.export') }}
					</NButton>

					<input id="fileInput" type="file" style="display:none" @change="importData">
					<NButton size="small" @click="handleImportButtonClick">
						<template #icon>
							<SvgIcon icon="ri:upload-2-fill"/>
						</template>
						{{ $t('common.import') }}
					</NButton>

					<NPopconfirm placement="bottom" @positive-click="clearData">
						<template #trigger>
							<NButton size="small">
								<template #icon>
									<SvgIcon icon="ri:close-circle-line"/>
								</template>
								{{ $t('common.clear') }}
							</NButton>
						</template>
						{{ $t('chat.clearHistoryConfirm') }}
					</NPopconfirm>
				</div>
			</div>
			<div class="flex items-center space-x-4">
				<span class="flex-shrink-0 w-[100px]">{{ $t('setting.theme') }}</span>
				<div class="flex flex-wrap items-center gap-4">
					<template v-for="item of themeOptions" :key="item.key">
						<NButton
							size="small"
							:type="item.key === theme ? 'primary' : undefined"
							@click="appStore.setTheme(item.key)"
						>
							<template #icon>
								<SvgIcon :icon="item.icon"/>
							</template>
						</NButton>
					</template>
				</div>
			</div>
			<div class="flex items-center space-x-4">
				<span class="flex-shrink-0 w-[100px]">{{ $t('setting.language') }}</span>
				<div class="flex flex-wrap items-center gap-4">
					<NSelect
						style="width: 140px"
						:value="language"
						:options="languageOptions"
						@update-value="value => appStore.setLanguage(value)"
					/>
				</div>
			</div>

			<br>
			<n-input-group>
				<input v-model="state.apikey" style="width: 90%;border: 1px #659a65 solid;border-radius: 3px;"/>
				<n-button type="primary" :disabled="state.jihuoids"
									:loading="state.jihuoloading" @click="jihuo()" ghost>
					{{ state.jihuotext }}
				</n-button>
			</n-input-group>
			<!--      <div class="flex items-center space-x-4">-->
			<!--        <span class="flex-shrink-0 w-[100px]">{{ $t('setting.resetUserInfo') }}</span>-->
			<!--        <NButton size="small" @click="handleReset">-->
			<!--          {{ $t('common.reset') }}-->
			<!--        </NButton>-->
			<!--      </div>-->
		</div>
	</div>
</template>
