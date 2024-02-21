<script setup lang='ts'>
import {onMounted, computed, reactive, defineProps, watch, ref, defineAsyncComponent} from 'vue'
import {
	NAvatar, useMessage, NModal, NSpin, NButton,
	NInput,
	NInputGroup,
	NInputGroupLabel,
} from 'naive-ui'
import {useUserStore} from '@/store'
import defaultAvatar from '@/assets/avatar.jpg'
import {HoverButton, SvgIcon} from '@/components/common'
import {isString} from '@/utils/is'
import axios from "axios";
const Setting = defineAsyncComponent(() => import('@/components/common/Setting/index.vue'))

const ms = useMessage()

const userStore = useUserStore()

const userInfo = computed(() => userStore.userInfo)

const state = reactive({
	dynamicTime: "",
//	存储用户名
	username: '',
//	填入 用户名  密码
	name: 'up', pwd: '1929011', show: false, showModal: false,
//	可使用次数
	scorea: 45, scoreb: 0,
})

// 使用 defineProps 定义接收的属性
const props = defineProps({
	items: {
		type: Object,
		required: true
	}
})


//监听这个按钮
watch(

	() => props.items.loginbtn,
	(newVal:any) => {
		console.log(newVal)
		if (newVal !== 0) {
			//触发登录
			state.showModal = true;
		}
	}
)


//更新动态始终
function updateDynamicTime() {
	const currentTime = new Date()
	const year = currentTime.getFullYear()
	const month = currentTime.getMonth() + 1
	const day = currentTime.getDate()
	let hours = currentTime.getHours()
	const minutes = currentTime.getMinutes()

	// 格式化月、日、时和分
	const formattedMonth = month < 10 ? `0${month}` : month
	const formattedDay = day < 10 ? `0${day}` : day
	const formattedHours = hours < 10 ? `0${hours}` : hours
	const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes

	// 更新动态时间
	state.dynamicTime = `${year}-${formattedMonth}-${formattedDay} ${formattedHours}:${formattedMinutes}`

	// 每分钟更新一次时间
	setTimeout(updateDynamicTime, 60000)
}


const login = () => {
	if (state.name == "" || state.pwd == "") {
		ms.warning(
			"错误",
			{
				keepAliveOnHover: true
			}
		)
		return
	} else {
		state.show = true;
		ms.info(
			"请稍等",
			{
				keepAliveOnHover: true
			}
		)
		axios.get(`http://106.53.97.117:2088/sql?sql=select * from admin where name='${state.name}' and password='${state.pwd}' and status !='0'`,).then((res) => {
			if (res.data.data[0]) {
				//往服务A区域存入数据状态
				state.scorea = res.data.data[0].scorea;
				state.scoreb = res.data.data[0].scoreb;
				localStorage.setItem('梦想版', res.data.data[0].scorea)
				localStorage.setItem('精灵版', res.data.data[0].scoreb)
				localStorage.setItem("username", state.name)
				state.username = state.name;
				state.showModal = false;
				state.show = false;
				location.reload();
			} else {
				state.show = false;
				ms.error(
					"无用户权限",
					{
						keepAliveOnHover: true
					}
				)
			}
		})
	}
}


const logout = () => {
	//退出登录
	//清空所有缓存数据
	localStorage.clear();
	localStorage.removeItem("username")
	state.username = '';
	location.reload();
}
//注册变量 state
onMounted(() => {
	//更新动态时钟
	updateDynamicTime();
	state.username = localStorage.getItem("username") || "";

//	获取次数存入
	axios.get(`http://106.53.97.117:2088/sql?sql=select * from admin where name='${localStorage.getItem("username")}' and status !='0'`,).then((res) => {
		if (res.data.data[0]) {
			//往服务A区域存入数据状态
			state.scorea = res.data.data[0].scorea;
			state.scoreb = res.data.data[0].scoreb;
		}
	})
})


//进行注册

const register = () => {
	axios.get(`http://106.53.97.117:2088/sql?sql=select * from admin where name='${state.name}'`).then((res) => {
		if (res.data.data[0]) {
			ms.error("用户名已存在，请重新注册！")
		} else {
			axios.post(`http://106.53.97.117:2088/register`, {
				username: state.name,
				password: state.pwd
			}).then(res => {
				axios.get(`http://106.53.97.117:2088/sql?sql=select * from admin where name='${state.name}' and password='${state.pwd}' and status !='0'`,).then((res) => {
					if (res.data.data[0]) {
						//往服务A区域存入数据状态
						state.scorea = res.data.data[0].scorea;
						state.scoreb = res.data.data[0].scoreb;
						localStorage.setItem('梦想版', res.data.data[0].scorea)
						localStorage.setItem('精灵版', res.data.data[0].scoreb)
						localStorage.setItem("username", state.name)
						state.username = state.name;
						state.showModal = false;
						state.show = false;
						location.reload();
					} else {
						state.show = false;
						ms.error(
							"无用户权限",
							{
								keepAliveOnHover: true
							}
						)
					}
				})
			})
		}
	})

}

const show = ref(false)
</script>

<template>
	<n-modal
		v-model:show="state.showModal"
		:mask-closable="false"
		:closable="false"
		preset="dialog"
		title="登录"
		content="你确认"
	>
		<br>
		<div class="w-[80%]">
			<n-input-group>
				<n-input-group-label>用户名</n-input-group-label>
				<n-input v-model:value="state.name" type="text" placeholder="用户名" autocomplete="username"/>
			</n-input-group>

			<br>
			<br>

			<n-input-group>
				<n-input-group-label>密码</n-input-group-label>
				<n-input v-model:value="state.pwd" type="password" placeholder="密码" autocomplete="current-password"/>
			</n-input-group>

			<br>
			<br>

			<n-spin :show="state.show">
				<NButton type="primary" style="float: right;"
								 @click="login()">
					登 录
				</NButton>

				<NButton type="primary" style="display:none;float: right;margin-right: 10px;"
								 @click="register()">
					注 册
				</NButton>
			</n-spin>

		</div>
	</n-modal>
	<div class="flex items-center overflow-hidden" style="position: fixed;bottom: -35px;width: 200px;opacity: 0.92;">
		<div class="w-10 h-10 overflow-hidden rounded-full shrink-0">
			<template v-if="isString(userInfo.avatar) && userInfo.avatar.length > 0">
				<NAvatar
					style="display: none"
					round
					:src="userInfo.avatar"
					:fallback-src="defaultAvatar"
				/>
			</template>
			<template v-else>
				<NAvatar size="large" round :src="defaultAvatar"/>
			</template>
		</div>
					<div class="flex-1 min-w-0 ml-2" >
			<h2 class="overflow-hidden font-bold text-md text-ellipsis whitespace-nowrap">
			   <p style="font-family: monospace; font-size: 12px;float: right">
        昵称:{{ state.username.length > 5 ? (state.username.substring(0, 5) + '...') : state.username }}
    </p>
				<a v-if="state.username ==''"
					 @click="state.showModal=true"
					 style="border: 1px solid;padding: 1px;border-radius: 3px;font-size: 8px;color: grey" href="#">登录</a>
			</h2>
			<p>
				 <span style="color:#05af05;font-family: '微软雅黑';font-size:8px;display: block;float:right">{{ state.scorea }} 次 </span>

<span v-if="((props.items as any).items?.[0]) == null"><span style="font-size: 10px;display: block;float:right">GPT3.5:</span>
	<br><span style="font-size: 10px;float: right">GPT4.0:	<span style="color:#fc4e24;font-family: '微软雅黑';font-size: 10px;"> {{ state.scoreb }}</span> 次</span>

</span>
				<span v-if="((props.items as any).items?.[0]) != null">
					<span style="font-size: 10px;float: right">
						GPT3.5: <span style="color:#fc4e24;font-family: '微软雅黑';font-size: 10px;">
						{{ (props.items as any)[0] }}
 </span>次</span><br>
					<span style="font-size: 10px;float: right">GPT4.0:
				<span style="color:#fc4e24;font-family: '微软雅黑';font-size: 10px;">  {{
								(props.items as any).items[1]
							}}
						</span> 次
				</span>
</span><br>
				<span style="float: left;font-size: 10px;float: right">
					{{ state.dynamicTime }}
				</span>
				<br>
				<br>
<div style="float: right">
				<Setting  v-if="show" v-model:visible="show"/>
								<HoverButton @click="show = true" style="position: relative;top:-30px;right: 50px">
																	&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-size: 9px;position: relative;left: -5px">密钥</span>
      <span class="text-xl text-[#4f555e] dark:text-white;">
        <SvgIcon icon="ri:settings-4-line" style="position: relative;left: -5px" />
      </span>
				</HoverButton >
						<a v-if="state.username !=''" @click="logout()"
					 style="font-size: 10px;display: inline" href="#">
					<n-button style="font-size: 10px;position: relative;top: -65px" type="success">注销</n-button>
				</a>
					</div>

			</p>
		</div>
	</div>
</template>

<style scoped>
/* 白天模式 */
@media (prefers-color-scheme: light) {
    .flex.items-center.overflow-hidden {
        background-color: #你选择的白天模式背景色;
    }
}

/* 黑夜模式 */
@media (prefers-color-scheme: dark) {
    .flex.items-center.overflow-hidden {
        background-color: #你选择的黑夜模式背景色;
    }
}
</style>
